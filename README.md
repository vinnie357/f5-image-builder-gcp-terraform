# f5-image-builder-gcp-terraform
using gcp resources created with terraform to take advantage of the f5-image-builder

# setup and run imagebuilder in google cloud

#https://github.com/f5devcentral/f5-bigip-image-generator

# setup
https://github.com/f5devcentral/f5-bigip-image-generator/blob/master/setup-build-env

# overview
- ## create disk
- ## create vmx enabled image
- ## create build machine in gcp
- ## create buckets/storage
- ## run setup
- ## get images/isos
- ## get artifacts
- ## build images and output to bucket

# logs
/var/log/startup-script.log
```bash
tail -f /var/log/startup-script.log
```

# issues
- User '' was added to the 'kvm' group.  You must log out and log back in to
  pick up the permissions changes for this user.
- uploading source ISO is an issue.
  convert to bucket? and source from there?

# running:
```bash
make build
make gcp
```
download your required ISO from downloads.f5.com
ex: https://downloads.f5.com/esd/serveDownload.jsp?path=/big-ip/big-ip_v15.x/15.1.0/english/15.1.0/&sw=BIG-IP&pro=big-ip_v15.x&ver=15.1.0&container=15.1.0&file=BIGIP-15.1.0-0.0.31.iso

add key to your shell session
-----------------------
```bash
eval $(ssh-agent -s)

ssh-add ~/.ssh/key
ip="35.237.100.83"
scp BIGIP-15.1.0-0.0.31.iso xadmin@$ip:/var/tmp/BIGIP-15.1.0-0.0.31.iso
scp BIGIP-15.1.0-0.0.31.iso.384.sig xadmin@$ip:/var/tmp/BIGIP-15.1.0-0.0.31.iso.384.sig


ssh xadmin@xadmin@35.231.179.56

# or
scp -i ~/.ssh/key BIGIP-15.1.0-0.0.31.iso xadmin@$ip:/var/tmp/BIGIP-15.1.0-0.0.31.iso
scp -i ~/.ssh/key BIGIP-15.1.0-0.0.31.iso.384.sig xadmin@$ip:/var/tmp/BIGIP-15.1.0-0.0.31.iso.384.sig
ssh -i ~/.ssh/key xadmin@xadmin@$ip
cd /f5-bigip-image-generator/

sudo ./build-image -i /var/tmp/BIGIP-15.1.0-0.0.31.iso -c config.yml -p gce -m all -b 1 --log-level DEBUG
```
# custom images
TLDR: 
- you need a custom role for a service account to create images:
  https://cloud.google.com/compute/docs/images/managing-access-custom-images
- In order to use a custom role the name must be fully qualified:
  https://github.com/terraform-providers/terraform-provider-google/issues/993
  eg:
  role    = "projects/${data.google_project.builder.project_id}/roles/${google_project_iam_custom_role.customImageRole.role_id}"
## to create custom roles you will need
- Role Administrator
- Project IAM Admin

# troubleshooting service accounts
- list service accounts
curl -v -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/' -H 'Metadata-Flavor: Google'
- get token for service account
- ### default
token=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' -H 'Metadata-Flavor: Google' | jq -r .access_token )
- get bucket info
https://compute.googleapis.com/compute/v1/projects/projectname/global/images/f5-bigip-15-1-0-0-0-31-byol-all-1slot-xwusf64zh?alt=json
curl -v -f --retry 20 "https://compute.googleapis.com/compute/v1/projects/projectname/global/images/f5-bigip-15-1-0-0-0-31-byol-all-1slot-xwusf64zh" -H "Metadata-Flavor: Google" -H "Authorization: Bearer $token"