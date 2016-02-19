FROM nginx:1.9.9

RUN rm /etc/nginx/conf.d/default.conf

COPY global.conf.template /etc/nginx/conf.d/
COPY *.conf /etc/nginx/conf.d/
COPY includes/ /etc/nginx/conf.d/includes/
COPY run_nginx.sh /opt/run_nginx.sh
COPY assets/images/placeholder.jpg /usr/share/nginx/html/placeholder.jpg 

CMD bash /opt/run_nginx.sh
