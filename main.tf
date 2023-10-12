resource "google_compute_instance" "server" {
    name         = "minecraft-server"
    machine_type = var.machine_type
    zone         = var.zone

    tags = [ "minecraft" ]
    
    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    network_interface {
        network = "default"
        access_config {
            nat_ip = google_compute_address.ip.address
        }
    }
}

resource "google_compute_firewall" "minecraft" {
    name    = "allow-minecraft"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = [var.server_port]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = [ "minecraft" ]
}

resource "google_compute_address" "ip" {
    name = "minecraft-ip"
    region = var.region
    network_tier = var.network_tier
}