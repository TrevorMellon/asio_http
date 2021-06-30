#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#

# Prevent GoogleTest from overriding our compiler/linker options
# when building with Visual Studio
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

enable_testing()

if( BUILD_ASIO_HTTP_TESTS )
  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        release-1.8.0
  )
  FetchContent_MakeAvailable(googletest)
  add_subdirectory(test)
  add_subdirectory(test_server)
  add_subdirectory(examples)
endif( BUILD_ASIO_HTTP_TESTS )