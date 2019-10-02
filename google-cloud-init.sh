#!/usr/bin/env bash

# Deploy to GKE, https://cloud.google.com
#
# Required globals:
#   GOOGLE_KEY_FILE
#   GOOGLE_PROJECT
#   GOOGLE_PROJECT_REGION
#   GOOGLE_PROJECT_ZONE
#   GKE_CLUSTER_NAME
# Optional globals:
#   DEBUG

source "$(dirname "$0")/cloud-env-common.sh"
enable_debug

# mandatory parameters
GOOGLE_KEY_FILE=${GOOGLE_KEY_FILE:?'GOOGLE_KEY_FILE variable missing.'}
GOOGLE_PROJECT=${GOOGLE_PROJECT:?'GOOGLE_PROJECT variable missing.'}
GOOGLE_PROJECT_REGION=${GOOGLE_PROJECT_REGION:?'GOOGLE_PROJECT_REGION variable missing.'}
GOOGLE_PROJECT_ZONE=${GOOGLE_PROJECT_ZONE:?'GOOGLE_PROJECT_ZONE variable missing.'}
GKE_CLUSTER_NAME=${GKE_CLUSTER_NAME:?'GKE_CLUSTER_NAME variable missing.'}

info "Setting up GCP environment".

run 'echo "${GOOGLE_KEY_FILE}" | base64 -d >> /opt/keys/system-account.json'
mkdir /opt/keys

run gcloud auth activate-service-account --key-file /opt/keys/system-account.json --quiet ${gcloud_debug_args}
export GOOGLE_APPLICATION_CREDENTIALS=/opt/keys/system-account.json

run gcloud config set project ${GOOGLE_PROJECT} --quiet ${gcloud_debug_args}
run gcloud config set compute/region ${GOOGLE_PROJECT_REGION} --quiet ${gcloud_debug_args}
run gcloud config set compute/zone ${GOOGLE_PROJECT_ZONE} --quiet ${gcloud_debug_args}
run gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GOOGLE_PROJECT_ZONE} --project ${GOOGLE_PROJECT} --quiet ${gcloud_debug_args}
run gcloud auth configure-docker --quiet ${gcloud_debug_args}
