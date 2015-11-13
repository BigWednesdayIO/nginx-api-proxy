FROM nginx

RUN rm /etc/nginx/conf.d/default.conf

COPY global.conf.template /etc/nginx/conf.d/
COPY *.conf /etc/nginx/conf.d/
COPY includes/ /etc/nginx/conf.d/includes/
COPY run_nginx.sh /opt/run_nginx.sh

CMD bash /opt/run_nginx.sh
