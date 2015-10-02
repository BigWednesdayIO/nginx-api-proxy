FROM nginx
COPY big-wednesday.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
