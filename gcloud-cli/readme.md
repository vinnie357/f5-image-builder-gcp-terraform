```bash
make shell

gcloud auth login

gcloud config set project <PROJECT_ID>

gcloud compute images list --filter="name=( 'ubuntu' )"
bash-5.0# gcloud compute images list ubuntu-1804-bionic-v20200218 --uri
https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20200218

```