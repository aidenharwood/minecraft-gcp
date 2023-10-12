data "google_compute_image" "image" {
    name = local.image_name
    project = local.image_project
}