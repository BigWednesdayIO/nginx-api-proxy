#! /bin/bash

set -e

# Write environment variables into the nginx config (they are not supported natively)
cat /etc/nginx/conf.d/global.conf.template | perl -pe 's/\{\{(\w+)\}\}/$ENV{$1}/eg' > /etc/nginx/conf.d/global.conf

echo "Using config"
cat /etc/nginx/conf.d/global.conf
cat /etc/nginx/conf.d/big-wednesday.conf
cat /etc/nginx/conf.d/orderable.conf

nginx -g "daemon off;";
