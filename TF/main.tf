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
