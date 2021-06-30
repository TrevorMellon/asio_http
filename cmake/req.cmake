#
#    asio_http: http client library for boost asio
#    Copyright (c) 2017-2019 Julio Becerra Gomez
#    See COPYING for license information.
#

find_package( Boost COMPONENTS system REQUIRED )

find_package( OpenSSL REQUIRED )

find_package( ZLIB REQUIRED )

find_package( Threads )