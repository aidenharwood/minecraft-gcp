output "ip" {
    value = google_compute_address.ip.address
}

output "instance_name" {
    value = google_compute_instance.server.name
}