resource "google_compute_instance" "server" {
    name         = "minecraft-server"
    machine_type = local.machine_type
    zone         = var.zone

    tags = [ "minecraft" ]
    
    boot_disk {
        source = google_compute_disk.boot.self_link
    }

    network_interface {
        network = "default"
        access_config {
            nat_ip = google_compute_address.ip.address
            network_tier = var.network_tier
        }
    }
    
    attached_disk {
        source = google_compute_disk.storage.self_link
    }

    metadata_startup_script = file("scripts/setup_minecraft.sh")

    allow_stopping_for_update = true
}

resource "google_compute_firewall" "firewall" {
    name    = "allow-minecraft"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = [var.server_java_port]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = [ "minecraft" ]
}

resource "google_compute_firewall" "firewall" {
    name    = "allow-minecraft"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = [var.server_bedrock_port]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = [ "minecraft" ]
}

resource "google_compute_address" "ip" {
    name = "minecraft-ip"
    region = var.region
    network_tier = var.network_tier
}

resource "google_compute_disk" "boot" {
    name = "minecraft-boot-disk"
    type = "pd-balanced"
    size = var.vm_boot_disk_size
    image = data.google_compute_image.image.self_link
}

resource "google_compute_disk" "storage" {
    name = "minecraft-storage-disk"
    type = "pd-balanced"
    size = var.vm_disk_size
}