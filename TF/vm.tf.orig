resource "google_compute_instance" "phil_mongodb_vm" {
  name         = "phil-mongodb-vm"
  machine_type = "e2-medium"   # Adjust the machine type if needed
  zone         = "us-central1-a"  # Match the zone with the subnet and region

  # Boot disk
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210817"  # Use Ubuntu 20.04 image
    }
  }

  # Network interface
  network_interface {
    network    = "${var.project_id}-vpc" #google_compute_network.custom_vpc.name
    subnetwork = "${var.project_id}-subnet" #google_compute_subnetwork.custom_subnet.name

    access_config {
      // Assigns an external IP address
    }
  }

  # Startup script to install MongoDB
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y mongodb
    systemctl start mongodb
    systemctl enable mongodb
    EOT
}

# Output the external IP address of the MongoDB VM
output "external_ip" {
  value = google_compute_instance.phil_mongodb_vm.network_interface[0].access_config[0].nat_ip
}


