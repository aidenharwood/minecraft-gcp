data "google_compute_image" "image" {
    family = local.image_name
    project = local.image_project
}