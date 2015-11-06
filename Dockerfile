FROM nginx

RUN rm /etc/nginx/conf.d/default.conf

COPY big-wednesday.conf.template /etc/nginx/conf.d/
COPY includes/ /etc/nginx/conf.d/includes/
COPY run_nginx.sh /opt/run_nginx.sh

CMD bash /opt/run_nginx.sh
