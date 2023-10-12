locals {
    image_project = split("/", var.image)[0]
    image_name = split("/", var.image)[1]
    machine_type = "custom-${var.vm_cores}-${var.vm_memory}"
}