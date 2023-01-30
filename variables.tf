#GLOBAL variables
variable "data_center" {default = "terrad"}
variable "cluster" {default = "terrac"}
variable "workload_datastore" {default = "DatastoreCluster"}
variable "admin_password" {default = "Welcome1!"}
variable "join_domain" {default = "terra.lab"}
variable "domain_admin_user" {default = "administrator@terra.lab"}
variable "domain_admin_password" {default = "Welcome1!"}
variable "datacenter" {default = "33"}

#VM specific variables
variable "name" {}
variable "num_cpus" {}
variable "memory" {}
variable "os_disk_size" {}
variable "environment" {}
variable "environment_options" {
  default = {
    "Production" = "PC"
    "Preview" = "SC"
    "Shared" = "SS"
    "DisasterRecovery" = "PD"
 }
}
variable "os" {}
variable "OSVersions" {
  default = {
    "Windows2008" = "W2008"
    "Windows2012" = "W2012"
    "Windows2016" = "W2016"
    "Windows2019" = "W2019"
 }
}
variable "additional_disk_selector" {}
variable "additional_disk_number" {type = list(string)}
variable "additional_disk_sizes" {type = list(string)}
variable "additional_disk_number_null" {
type = list(string)
default = []
}
variable "additional_disk_sizes_null" {
type = list(string)
default = []
}
variable "additional_disk_selector_options" {
  default = {
    "0" = "0"
    "1" = "1"
    "False" = "0"
    "True" = "1"
    "Disable" = "0"
    "Enable" = "1"
    "No" = "0"
    "Yes" = "1"
 }
}
variable "network_interface" {type = list(string)}
variable "network_interface_ip" {type = list(string)}

#GLOBAL datasets
data "vsphere_datacenter" "dc" {
  name                      = var.data_center
}
data "vsphere_compute_cluster" "cluster" {
  name                      = var.cluster
  datacenter_id             = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore_cluster" "datastore_cluster" {
  name                      = var.workload_datastore
  datacenter_id             = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  for_each 		    = zipmap(var.network_interface,var.network_interface_ip)
  name                      = each.key
  datacenter_id             = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "Win2012Template" {
  name                      = "${lookup(var.OSVersions, format("%s", var.os))}"
  datacenter_id             = data.vsphere_datacenter.dc.id
}
