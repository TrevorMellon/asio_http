#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#

if( ( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" ) AND NOT( CMAKE_CXX_COMPILER_VERSION LESS 5.0 ) )
  set(HAS_CORO 1)
endif()

if(HAS_CORO)
 set(CORO_FLAGS "-fcoroutines-ts -stdlib=libc++")
else()
 set(CORO_FLAGS "")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CORO_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)