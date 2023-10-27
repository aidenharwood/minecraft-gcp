locals {
    image_project = split("/", var.image)[0]
    image_name = split("/", var.image)[1]
    vm_memory = var.vm_memory * 1024
    machine_type = coalesce(var.vm_sku, "custom-${var.vm_cores}-${local.vm_memory}")
}