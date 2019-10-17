/**
    asio_http: http client library for boost asio
    Copyright (c) 2017-2019 Julio Becerra Gomez
    See COPYING for license information.
*/

#include "asio_http/internal/request_manager.h"

#include "asio_http/error.h"
#include "asio_http/http_request_interface.h"
#include "asio_http/http_request_result.h"
#include "asio_http/internal/completion_handler_invoker.h"
#include "asio_http/internal/http_client_connection.h"
#include "asio_http/internal/http_error_handling.h"
#include "asio_http/internal/logging_functions.h"

#include "loguru.hpp"

#include <boost/asio.hpp>
#include <cinttypes>
#include <memory>
#include <utility>
#include <vector>

namespace asio_http
{
namespace internal
{
namespace
{
http_request_result
create_request_result(const request_data& request, request_buffers&& request_buffers, std::error_code ec)
{
  http_request_result result(request_buffers.m_status_code,
                             std::move(request_buffers.m_headers),
                             request_buffers.m_data_sink.get_data(),
                             ec,
                             get_request_stats(request.m_creation_time));

  http_request_stats_logging(result, request.m_http_request->get_url().to_string());

  return result;
}
}  // namespace
request_manager::request_manager(const http_client_settings& settings, boost::asio::io_context& io_context)
    : m_settings(settings)
    , m_strand(io_context)
    , m_connection_pool(m_strand)
{
}

request_manager::~request_manager()
{
}

void request_manager::execute_request(const request_data& request)
{
  m_requests.insert(request);
  execute_waiting_requests();
  DLOG_F(INFO, "New request added");
}

void request_manager::cancel_requests(const std::string& cancellation_token)
{
  request_list::index_iterator<index_cancellation>::type it;
  auto&                                                  index = m_requests.get<index_cancellation>();
  while ((it = cancellation_token.empty() ? index.begin() : index.find(cancellation_token)) != index.end())
  {
    cancel_request(index, it);
  }
}

template<typename Iterator, typename Index>
void request_manager::cancel_request(Index& index, const Iterator& it)
{
  if (it->m_connection)
  {
    it->m_connection->cancel();
  }
  else
  {
    handle_completed_request(index, it, http_request_result{});
  }
}

template<typename Iterator, typename Index>
void request_manager::handle_completed_request(Index& index, const Iterator& iterator, http_request_result&& result)
{
  completion_handler_invoker::invoke_handler(*iterator, std::move(result));
  index.erase(iterator);
  m_strand.post([ptr = this->shared_from_this()]() { ptr->execute_waiting_requests(); });
}

void request_manager::on_request_completed(request_buffers&&                       request_buffers,
                                           std::shared_ptr<http_client_connection> handle,
                                           boost::system::error_code               ec)
{
  m_connection_pool.release_connection(handle, static_cast<bool>(ec));

  auto&      index = m_requests.get<index_connection>();
  const auto it    = index.find(handle);
  if (it != m_requests.get<index_connection>().end())
  {
    const auto error_handling = process_errors(ec, request_buffers);
    if (error_handling.first && it->m_retries < m_settings.max_attempts)
    {
      index.modify(it, [newrequest = std::move(error_handling.second)](request_data& request) {
        if (newrequest)
        {
          request.m_http_request = newrequest;
        }
        request.m_connection.reset();
        request.m_request_state = request_state::waiting_retry;
        request.m_retries++;
      });
      m_strand.post([ptr = this->shared_from_this()]() { ptr->execute_waiting_requests(); });
    }
    else
    {
      handle_completed_request(
        index, it, create_request_result(*it, std::move(request_buffers), asio_mapped_error::convert(ec)));
    }
  }
}

void request_manager::execute_waiting_requests()
{
  auto& index = m_requests.get<index_state>();

  const auto active_requests = index.count(request_state::in_progress);
  const auto it              = index.begin();
  if (active_requests < m_settings.max_parallel_requests && it != index.end() &&
      it->m_request_state != request_state::in_progress)
  {
    const auto host_port = std::make_pair(it->m_http_request->get_url().host, it->m_http_request->get_url().port);
    const auto handle    = m_connection_pool.get_connection(host_port);
    const auto request   = it->m_http_request;
    index.modify(it, [&handle](request_data& request) {
      request.m_connection    = handle;
      request.m_request_state = request_state::in_progress;
    });
    handle->start(request, [ptr = this->shared_from_this()](auto&& request_data, auto&& handle, auto&& ec) {
      ptr->on_request_completed(std::forward<decltype(request_data)>(request_data), handle, ec);
    });
  }
}
}  // namespace internal
}  // namespace asio_http
