resource "google_project_service" "project" {
    project = var.project
    service = "compute.googleapis.com"  
}

resource "google_compute_instance" "server" {
    name         = "minecraft-server"
    machine_type = var.machine_type
    zone         = var.zone
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
    metadata_startup_script = file("scripts/setup_minecraft.sh")
}

resource "google_compute_address" "ip" {
    name = "minecraft-ip"
    region = var.region
}