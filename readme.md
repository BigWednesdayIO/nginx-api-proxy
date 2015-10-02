# NGINX API Proxy for Google container engine
This repos contains a docker image and config for an TLS api proxy to work in Google Container Engine.

## Secret
 Use a kubernetes secret to manage the ssl certificate. The container specified in **rc.yaml** expects the secret to be called `starbigwednesdayio` use the **build-ssl-secret.js** script to create the secret passing in paths to relevant crt and key files, this will output a JSON file containing the secret.

``` javascript
node build-ssl-secret.js starbigwednesdayio path-to-cert path-to-key
```

## Deployment steps
 - Create the secret:
 ``` shell
 kubectl create -f ./starbigwednesdayio-secret.json
 ```
 - Set project id:
 ``` shell
 export PROJECT_ID=first-footing-108508
 ```
 - Build the image and push to the container engine (/set the image version tag as appropriate/)
 ``` shell
 docker build -t gcr.io/${PROJECT_ID}/nginx-api-proxy:v1 .
 ```
 ``` shell
 gcloud docker push gcr.io/${PROJECT_ID}/nginx-api-proxy:v1
 ```
 - Create the service:
 ``` shell
 kubectl create -f ./kubernetes/service.yml
 ```
 - Create the replication controller (note that the image field must refer to the image and tag created above):
 ``` shell
 kubectl create -f ./kubernetes/rc.yaml
 ```

## Useful docs
- http://kubernetes.io/v1.0/docs/user-guide/connecting-applications.html#securing-the-service
- http://blog.kubernetes.io/2015/07/strong-simple-ssl-for-kubernetes.html

