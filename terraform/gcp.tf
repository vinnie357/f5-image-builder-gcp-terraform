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
  sa_file = "${yamlencode(base64decode(google_service_account_key.builder.private_key))}"
  sa_name = "${google_service_account.builder-server.email}"
  
}

# Or use an existing project, if defined
data "google_project" "builder" {
  project_id = "${data.vault_generic_secret.gcp_creds_file.data["project_id"]}"
}

# Create the builder service account
resource "google_service_account" "builder-server" {
  account_id   = "builder-server"
  display_name = "builder Server"
  project      = data.google_project.builder.project_id
  description = "build server service account"
}

# Create a service account key
resource "google_service_account_key" "builder" {
  service_account_id = google_service_account.builder-server.name
}
# create custom image builder role
resource "google_project_iam_custom_role" "customImageRole" {
  role_id     = "imageBuilderRole"
  title       = "customBuilderImageRole"
  description = "role for creating custom images for image builder"
  permissions = ["compute.images.create", "compute.images.list", "compute.disks.use", "compute.disks.list", "compute.images.get"]
}
# add roles to service account
resource "google_project_iam_binding" "builderRole" {
  project = data.google_project.builder.project_id
  role    = "projects/${data.google_project.builder.project_id}/roles/${google_project_iam_custom_role.customImageRole.role_id}"

  members = [
    "serviceAccount:${google_service_account.builder-server.email}",
  ]
}



# resource "local_file" "sa_file" {
#   content     = "${google_service_account_key.builder}"
#   filename    = "${path.module}/sa-debug.json"
# }