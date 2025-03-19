terraform {
    backend "gcs" { 
      bucket  = "terraform-state-jb-cicdproject"
      prefix  = "prod"
    }
}

provider "google" {
  project = "clgcporg10-163"
  region = "us-central1"
}
