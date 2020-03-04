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

scp BIGIP-15.1.0-0.0.31.iso xadmin@35.231.179.56:/var/tmp/BIGIP-15.1.0-0.0.31.iso

ssh xadmin@xadmin@35.231.179.56

# or
scp -i ~/.ssh/key BIGIP-15.1.0-0.0.31.iso xadmin@35.231.179.56:/var/tmp/BIGIP-15.1.0-0.0.31.iso
ssh -i ~/.ssh/key xadmin@xadmin@35.231.179.56

sudo ./build-image -i /var/tmp/BIGIP-15.1.0-0.0.31.iso -c config.yml -p gce -m all -b 1 --log-level DEBUG
```