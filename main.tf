resource "google_compute_network" "vpc_network" {
  name = "practice-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "practice-subnet"
  ip_cidr_range = "10.0.1.0/27"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ssh_rule" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "practice-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "Hello from Private VM Apache Server" > /var/www/html/index.html
  EOT
}
