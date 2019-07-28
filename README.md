1. `brew install nss mkcert`
1. `mkcert -install`
1. `cd config/ssl && mkcert lifework.test lifework-packs.test localhost 127.0.0.1 ::1 && cd ../../`
1. `bin/server`
