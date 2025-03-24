terraform {
    backend "gcs" { 
      bucket  = "terraformstate-cicd"
      prefix  = "prod"
    }
}

provider "google" {
  project = "clgcporg10-163"
  region = "us-central1"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "region" {
  default     =  "us-central1"
  description = "GCP region"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  version = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}



resource "google_storage_bucket" "static" {
 name          = "mongo-backup"
 location      = "US"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "member" {
  provider = google
  bucket   = google_storage_bucket.default.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}
