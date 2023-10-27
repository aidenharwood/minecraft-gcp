variable "service_account_email" {
  default = null
}
variable "project" {
  default = "my-project"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}
variable "image" {
  default = "debian-cloud/debian-12"
}
variable "network_tier" {
  default = "STANDARD"
}
variable "server_java_port" {
  default = 25565
}
variable "server_bedrock_port" {
  default = 19132
}
variable "vm_cores" {
  default = 1
}
variable "vm_memory" {
  default = 1
}
variable "vm_sku" {
  default = null
}
variable "vm_disk_size" {
  default = 10
}
variable "vm_boot_disk_size" {
  default = 10
}