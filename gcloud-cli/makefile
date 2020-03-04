.PHONY: build shell

export DIR = $(shell pwd)

pull: 
	docker pull google/cloud-sdk:latest

build: 
	docker build -t my-cloud-sdk-docker:alpine .

shell: pull run



run:
	@docker run -ti -e CLOUDSDK_CONFIG=/config/mygcloud \
	-v ${DIR}/mygcloud:/config/mygcloud \
	-v ${DIR}:/certs  google/cloud-sdk:alpine /bin/bash
run1:
	@docker run -ti \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
	my-cloud-sdk-docker:alpine /bin/bash

test: test1 test2

test1:
	@docker run -ti  google/cloud-sdk:latest gcloud version

test2:
	@docker run --rm -ti \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
    google/cloud-sdk:latest gcloud compute instances list --project ${GCP_PROJECT_ID}