# NGINX API Proxy for Google container engine
This repos contains a docker image and config for an TLS api proxy to work in Google Container Engine.

## SSH Keys
The domain certificate must be concatenated with additional the CA certifices bundle (domain certificate must be first):

``` shell
cat STAR_bigwednesday_io.crt STAR_bigwednesday_io.ca-bundle >> cert_chain.crt
```

The nginx proxy expects the following certs to exist and be valid:
  * /etc/nginx/ssl/starbigwednesdayio.crt
  * /etc/nginx/ssl/starbigwednesdayio.key
  * /etc/nginx/ssl/starorderableco.crt
  * /etc/nginx/ssl/starorderableco.key

This is achieved using a kubernets secret named `ssl-certificates"` which is mounted as a volume in **rc.json**.

Use the **build-ssl-secret.js** script to create the secret, passing in the path to a directory containing these files (e.g. /etc/nginx/ssl). This will output the secret as a JSON file which can be deployed using the kubernetes command line.

Create the secret:

``` shell
node build-ssl-secret.js /ssl_certs_directory
```

Deploy the secret:

``` shell
kubectl create -f ./ssl-certificates-secret.json
```

## Initial deployment

 ``` shell
 # Set required variables
 export PROJECT_ID=first-footing-108508
 export NAMESPACE=development
 export TAG=v1
 export QUALIFIED_IMAGE_NAME=eu.gcr.io/${PROJECT_ID}/nginx-api-proxy:${TAG}
 export DEPLOYMENT_ID=1

 # Build the image and push to the container engine
 docker build -t ${QUALIFIED_IMAGE_NAME} .
 gcloud docker push ${QUALIFIED_IMAGE_NAME}

 # Create the service
 cat ./kubernetes/service.json | \
    perl -pe 's/\{\{(\w+)\}\}/$ENV{$1}/eg' | \
    kubectl create --namespace=${NAMESPACE} -f -

 # Create the replication controller
 cat ./kubernetes/rc.json | \
    perl -pe 's/\{\{(\w+)\}\}/$ENV{$1}/eg' | \
    kubectl create --namespace=${NAMESPACE} -f -
 ```

## Update steps
 ``` shell
 # Set required variables
 export PROJECT_ID=first-footing-108508
 export NAMESPACE=development
 export TAG=v2
 export DEPLOYMENT_ID=2
 export QUALIFIED_IMAGE_NAME=eu.gcr.io/${PROJECT_ID}/nginx-api-proxy:${TAG}

 # Build the image and push to the container engine
 docker build -t ${QUALIFIED_IMAGE_NAME} .
 gcloud docker push ${QUALIFIED_IMAGE_NAME}

 # Peform a rolling update on the replication controller
 OLD_RC=$(~/google-cloud-sdk/bin/kubectl get rc -l "app=nginx" --namespace=${NAMESPACE} -o template --template="{{(index .items 0).metadata.name}}")

 export REPLICAS=$(~/google-cloud-sdk/bin/kubectl get rc ${OLD_RC} --namespace=${NAMESPACE} -o template --template="{{.spec.replicas}}")

 cat ./kubernetes/rc.json | \
    perl -pe 's/\{\{(\w+)\}\}/$ENV{$1}/eg' | \
    kubectl rolling-update ${OLD_RC} --namespace=${NAMESPACE} -f -
 ```

## Useful docs
- http://kubernetes.io/v1.0/docs/user-guide/connecting-applications.html#securing-the-service
- http://blog.kubernetes.io/2015/07/strong-simple-ssl-for-kubernetes.html
