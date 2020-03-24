# device
variable "sa_file" {
  description = "service account creds for builder tasks"
}
variable "sa_name" {
  description = "service account name for builder tasks"
}

variable "projectPrefix" {
  description = "prefix for resources"
}

variable "name" {
  description = "device name"
  default = "afm"
}
variable "region" {
  description = "All resources will be launched in this region."
  default = "us-east1"
}

variable "mgmt_vpc" {
  description = "main vpc"
}
variable "mgmt_subnet" {
  description = "main vpc subnet"
}
variable "deviceImage" {
 description = "gce image name"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-byol-all-modules-2boot-loc-191118"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-payg-best-1gbps-191118"
 default ="/projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20200218"
}

variable "MachineType" {
    description = " gce machine type/size"
    #default = "n1-standard-4"
    default = "n1-standard-8"
}

variable "vm_count" {
    description = " number of devices"
    default = 1
}

variable "adminSrcAddr" {
  description = "admin source range in CIDR"

}
variable adminAccountName { 
    default = "admin"
}
variable adminPass { 
    description = "bigip admin password"
    default = "admin"
 }
variable "gce_ssh_pub_key_file" {
    description = "path to public key for ssh access"
    default = "/root/.ssh/key.pub"
}
variable "project" {
  default = "none"
}
