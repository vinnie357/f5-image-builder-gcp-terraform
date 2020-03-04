provider "google" {
  #credentials = "${file("../${path.root}/creds/gcp/${var.GCP_SA_FILE_NAME}.json")}"
  #credentials = "${var.GCP_CREDS_FILE}"
  #credentials = "${jsondecode("${data.vault_generic_secret.gcp_creds_file.data_json}")}"
  credentials = "${data.vault_generic_secret.gcp_creds_file.data_json}"
  project     = "${data.vault_generic_secret.gcp_creds_file.data["project_id"]}"
  region      = "${var.GCP_REGION}"
  zone        = "${var.GCP_ZONE}"
}

# network
resource "google_compute_network" "vpc_network_mgmt" {
  name                    = "${var.projectPrefix}terraform-network-mgmt"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}
resource "google_compute_subnetwork" "vpc_network_mgmt_sub" {
  name          = "${var.projectPrefix}mgmt-sub"
  ip_cidr_range = "10.0.10.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.vpc_network_mgmt.self_link}"

}

module "builder" {
  source   = "./builder"
  #======================#
  # application settings #
  #======================#
  name = "${var.appName}"
  adminSrcAddr = "${var.adminSrcAddr}"
  mgmt_vpc = "${google_compute_network.vpc_network_mgmt}"
  mgmt_subnet = "${google_compute_subnetwork.vpc_network_mgmt_sub}"
  gce_ssh_pub_key_file = "${data.vault_generic_secret.gcp_pub_key.data["key"]}"
  adminAccountName = "${var.adminAccount}"
  projectPrefix = "${var.projectPrefix}"
  region = "${var.GCP_REGION}"
  project = "${data.vault_generic_secret.gcp_creds_file.data["project_id"]}"
}