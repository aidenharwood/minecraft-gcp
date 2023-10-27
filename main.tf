resource "google_compute_instance" "server" {
    name         = "minecraft-server"
    machine_type = local.machine_type

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

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
        email = var.service_account_email
    }

    metadata_startup_script = file("scripts/setup.sh")

    allow_stopping_for_update = true
}

resource "google_compute_firewall" "firewall_java" {
    name    = "allow-minecraft-java"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = [var.server_java_port]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = [ "minecraft" ]
}

resource "google_compute_firewall" "firewall_bedrock" {
    name    = "allow-minecraft-bedrock"
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

resource "google_compute_resource_policy" "daily_backup_policy" {
  name   = "daily-backup-policy"
  region = var.region
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 3
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = [var.region]
      labels = {
        environment = "production"
      }
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name = google_compute_resource_policy.policy.name
  disk = google_compute_disk.boot.name
  zone = var.zone
}