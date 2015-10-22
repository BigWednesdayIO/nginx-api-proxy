# NGINX API Proxy for Google container engine
This repos contains a docker image and config for an TLS api proxy to work in Google Container Engine.

## SSH Keys
The domain certificate must be concatenated with additional the CA certifices bundle (domain certificate must be first):

``` shell
cat STAR_bigwednesday_io.crt STAR_bigwednesday_io.ca-bundle >> cert_chain.crt
```

**big-wednesday.conf** expects a cert to be present at **/etc/nginx/ssl/starbigwednesdayio.crt** and the associated key to be present at **/etc/nginx/ssl/starbigwednesdayio.key**. This is achieved using a kubernets secret named `starbigwednesdayio` which is mounted as volume in **rc.json**.

Use the **build-ssl-secret.js** script to create the secret, passing in paths to relevant crt and key files, this will output the secret as a JSON file which can be deployed using the kubernetes command line.

Create the secret:

``` shell
node build-ssl-secret.js starbigwednesdayio ./cert_chain.crt ./my-key.key
```

Deploy the secret:

``` shell
kubectl create -f ./starbigwednesdayio-secret.json
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
