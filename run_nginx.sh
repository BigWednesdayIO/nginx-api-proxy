#! /bin/bash

set -e

(echo "upstream search_svc_url { server $SEARCH_API_SVC_SERVICE_HOST:$SEARCH_API_SVC_SERVICE_PORT; }" && \
  cat /etc/nginx/conf.d/big-wednesday.conf) > big-wednesday.conf.updated
mv big-wednesday.conf.updated /etc/nginx/conf.d/big-wednesday.conf

echo "Using config"
cat /etc/nginx/conf.d/big-wednesday.conf

nginx -g "daemon off;";

