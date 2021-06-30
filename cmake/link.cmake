#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#

target_link_libraries( ${PROJECT_NAME}
PUBLIC
  ${Boost_LIBRARIES}
  http_parser # public for errors enum
PRIVATE
  loguru
  ${ZLIB_LIBRARIES}
  ${CMAKE_DL_LIBS} # For loguru dladdr
  ${CMAKE_THREAD_LIBS_INIT}
  OpenSSL::SSL
)

target_include_directories( ${PROJECT_NAME}
    PUBLIC
        ${Boost_INCLUDE_DIRS}
    PRIVATE
        ${ZLIB_INCLUDE_DIR}
        ${OPENSSL_INCLUDE_DIR}
        http_parser
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    implementation/interface
    interface
)