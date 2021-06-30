#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#

cmake_minimum_required(VERSION 3.15)
include(FetchContent)
project(asio_http)

option(BUILD_ASIO_HTTP_TESTS "build tests and examples")

include ( cmake/compiler.cmake )

include ( cmake/req.cmake )

include ( cmake/src.cmake )

add_library( ${PROJECT_NAME} STATIC
  ${INTERFACE_FILES}
  ${IMPLEMENTATION_SOURCES}
  ${IMPLEMENTATION_HEADERS}
)

include ( cmake/link.cmake)

include ( cmake/tests.cmake)

add_subdirectory(loguru)
add_subdirectory(http_parser)
