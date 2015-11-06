#! /bin/bash

set -e

# Write environment variables into the nginx config (they are not supported natively)
cat /etc/nginx/conf.d/big-wednesday.conf.template | perl -pe 's/\{\{(\w+)\}\}/$ENV{$1}/eg' > /etc/nginx/conf.d/big-wednesday.conf

echo "Using config"
cat /etc/nginx/conf.d/big-wednesday.conf

nginx -g "daemon off;";
