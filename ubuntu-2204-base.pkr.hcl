packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
  }
}

variable "packer_password" {
  type = string
}

variable "preseed_http_ip" {
  type = string
}

variable "preseed_port_max" {
  type = string
}

variable "preseed_port_min" {
  type = string
}

variable "vcenter_cluster" {
  type = string
}

variable "vcenter_datastore" {
  type = string
}

variable "vcenter_folder" {
  type = string
}

variable "vcenter_iso_datastore" {
  type = string
}

variable "vcenter_iso_path" {
  type = string
}

variable "vcenter_network" {
  type = string
}

variable "vcenter_password" {
  type = string
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_username" {
  type = string
}

variable "vm_cpus" {
  type = string
}

variable "vm_disk" {
  type = string
}

variable "vm_memory" {
  type = string
}

variable "vm_name" {
  type = string
}

source "vsphere-iso" "ubuntu" {
  CPUs                 = "${var.vm_cpus}"
  RAM                  = "${var.vm_memory}"
  RAM_reserve_all      = true
  boot_command            = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  cluster              = "${var.vcenter_cluster}"
  convert_to_template  = "true"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = ["pvscsi"]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "ubuntu64Guest"
  http_directory       = "http"
  http_ip              = "${var.preseed_http_ip}"
  http_port_max        = "${var.preseed_port_max}"
  http_port_min        = "${var.preseed_port_min}"
  insecure_connection  = "true"
  iso_paths            = ["[${var.vcenter_iso_datastore}] ${var.vcenter_iso_path}"]
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "vmxnet3"
  }
  password     = "${var.vcenter_password}"
  ssh_password = "${var.packer_password}"
  ssh_username = "packer"
  storage {
    disk_size             = "${var.vm_disk}"
    disk_thin_provisioned = true
  }
  username       = "${var.vcenter_username}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.vm_name}"
  ssh_timeout    = "20m"
}

build {
  sources = ["source.vsphere-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/upgrade.sh"]
  }

}
