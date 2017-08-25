#!/usr/bin/env bash

set -o pipefail

shelldir=$(cd $(dirname $0) && pwd)

os=$(uname)

[ $os == 'Darwin' ] && host=$(ifconfig | grep -w 'inet' | grep -v '127.0.0.1' | awk '{ print $2 }')
[ $os == 'Linux' ] && host=$(hostname -i)

backend_port=8080
frontend_port=9000

function stop {
  # returns error code if no running container is found
  docker-compose -f $shelldir/docker-compose.yml down

  nones=$(docker images | grep "^<none>" | awk '{print $3}')

  # wc -w print the word count
  [ ! $(echo ${nones[@]} | wc -w) -eq 0 ] && docker rmi -f $nones
}

while (( $# > 0 ))
do
  opt=$1
  shift

  case ${opt} in
    -s)
      stop
      exit 0;
      ;;
    -b)
      backend_port=$1
      shift
      ;;
    -f)
      frontend_port=$1
      shift
      ;;
    *)
      echo "-b <backend_port>  | to specify the backend port, default value is 8080
            -f <frontend_port> | to specify the frontend port, default value is 9000
            -s                 | to stop the proxy"
      exit 0;
      ;;
  esac
done

cat << EOF > $shelldir/nginx.conf
server {
  listen *:80;

  location /user/login {
    proxy_pass http://$host:$backend_port;
  }

  location /api/ {
    proxy_pass http://$host:$backend_port;
  }

  location ~ /(info|health) {
    proxy_pass http://$host:$backend_port;
  }

  location ~ /(swagger|webjars|configuration|v2) {
    proxy_pass http://$host:$backend_port;
  }

  location / {
    proxy_pass http://$host:$frontend_port;
  }
}
EOF

stop

docker build -t dev-proxy -f $shelldir/Dockerfile $shelldir/.
docker-compose -f $shelldir/docker-compose.yml up -d

echo "nginx start. OS: $os, Host: $host, frontend: $frontend_port, backend: $backend_port"
