variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "user_ocid" {}
variable "ssh_public_key_file" {}
variable "private_key_path" {}
variable "availability_domain_name" {
  default     = null
}
#variable "is_always_free" {
#  default     = false
#}

## Compartment
#variable "dedicated_compartment" {
#  description = "Create a dedicated compartment"
#  default     = false
#}
variable "lab_name" {
  description = "Compartment name"
  default     = "upgrade"
}
#variable "delete_compartment" {
#  description = "Delete dedicated compartment"
#  default     = false
#}

# Networking
variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}
variable "vcn_dns_label" {
  default     = "lab"
}
#variable "public_sn_display_name" {
#  default     = "lab_public_subnet"
#}
variable "public_sn_dns_label" {
  default     = "lab"
}

# IP Assignment
#variable "public_ip_display_name" {
#  default     = "lab_public_ip"
#}

# Instance
variable "instance_shape" {
  default     = "VM.Standard.E3.Flex"
}
variable "ocpu_count" {
  default     = 2
}
variable "instance_memory" {
  default     = 32
}
variable "instance_name" {
  default     = "upgrade"
}
variable "block_volume_name" {
  default     = "Upgrade Volume"
}
variable "block_volume_size" {
  default     = 100
}
variable "bv_attachment_name" {
  default     = "/dev/oracleoci/oraclevdb"
}
variable "bv_attachment_display_name" {
  default     = "lab-bv-attachment"
}
variable "label_prefix" {
  default     = ""
}
variable "instance_os" {
  description = "Operating system."
  default     = "Oracle Linux"
}
variable "linux_os_version" {
  description = "Operating system version."
  default     = "7.9"
}
variable "generate_public_ssh_key" {
  default     = true
}
variable "public_ssh_key" {
  default     = ""
}

# Lab variables
variable "lab_version" {
  default     = 11
}
