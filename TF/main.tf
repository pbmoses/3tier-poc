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
