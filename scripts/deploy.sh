#! /bin/bash

set -e

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON_SITEPACKAGES=1

VERSION_ID=${CIRCLE_SHA1:0:7}
REMOTE_REPOSITORY=gcr.io/${CLOUDSDK_CORE_PROJECT}

# Build image
docker build -t ${REMOTE_REPOSITORY}/nginx-api-proxy:${VERSION_ID} .

# Authenticate gcloud SDK
echo $GCLOUD_KEY | base64 --decode > gcloud.p12
~/google-cloud-sdk/bin/gcloud auth activate-service-account $GCLOUD_EMAIL --key-file gcloud.p12
ssh-keygen -f ~/.ssh/google_compute_engine -N ""

# Set cluster
~/google-cloud-sdk/bin/gcloud container clusters get-credentials $GCLOUD_CLUSTER

# Push image to gcloud
~/google-cloud-sdk/bin/gcloud docker push ${REMOTE_REPOSITORY}/nginx-api-proxy:${VERSION_ID} > /dev/null

# Rolling update
OLD_RC=$(~/google-cloud-sdk/bin/kubectl get rc -l app=nginx | cut -f1 -d " " | tail -1)
~/google-cloud-sdk/bin/kubectl rolling-update ${OLD_RC} nginx-api-proxy-${VERSION_ID} --image=${REMOTE_REPOSITORY}/nginx-api-proxy:${VERSION_ID}
