#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#


set( INTERFACE_FILES
  interface/asio_http/coro_handler.h
  interface/asio_http/error.h
  interface/asio_http/future_handler.h
  interface/asio_http/http_request.h
  interface/asio_http/http_request_result.h
  interface/asio_http/http_client.h
  interface/asio_http/http_client_settings.h
  interface/asio_http/url.h
)

if( NOT HAS_CORO )
  list(REMOVE_ITEM INTERFACE_FILES interface/asio_http/coro_handler.h)
endif()

set( IMPLEMENTATION_SOURCES
  implementation/completion_handler_invoker.cpp
  implementation/connection_pool.cpp
  implementation/data_sink.cpp
  implementation/data_source.cpp
  implementation/http_client.cpp
  implementation/http_error_handling.cpp
  implementation/request_manager.cpp
  implementation/logging_functions.cpp
  implementation/compression.cpp
  implementation/http_request.cpp
  implementation/url.cpp
)

set( IMPLEMENTATION_HEADERS
  implementation/interface/asio_http/internal/completion_handler_invoker.h
  implementation/interface/asio_http/internal/http_client_connection.h
  implementation/interface/asio_http/internal/http_error_handling.h
  implementation/interface/asio_http/internal/connection_pool.h
  implementation/interface/asio_http/internal/data_sink.h
  implementation/interface/asio_http/internal/data_source.h
  implementation/interface/asio_http/internal/encoding.h
  implementation/interface/asio_http/internal/http_stack_shared.h
  implementation/interface/asio_http/internal/http_content.h
  implementation/interface/asio_http/internal/request_manager.h
  implementation/interface/asio_http/internal/logging_functions.h
  implementation/interface/asio_http/internal/request_data.h
  implementation/interface/asio_http/internal/tuple_ptr.h
  implementation/interface/asio_http/internal/compression.h
  implementation/interface/asio_http/internal/socket.h
)