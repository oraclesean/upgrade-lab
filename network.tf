resource "oci_core_virtual_network" "lab-vcn" {
  cidr_block      = var.vcn_cidr
  compartment_id  = var.compartment_ocid
  display_name    = "VCN"
  dns_label       = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "public_internet_gateway" {
  vcn_id          = oci_core_virtual_network.lab-vcn.id
  compartment_id  = var.compartment_ocid
  display_name    = "Internet gateway"
  enabled         = true
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.lab-vcn.id
  display_name    = "Public route table"
  route_rules {
    destination     = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.public_internet_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id  = var.compartment_ocid
  display_name    = "Public security list"
  vcn_id          = oci_core_virtual_network.lab-vcn.id
  egress_security_rules {
    destination     = "0.0.0.0/0"
    protocol        = "6"
  }
  ingress_security_rules {
    tcp_options {
      max             = 22
      min             = 22
    }
    protocol        = "6"
    source          = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "public" {
  cidr_block      = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name    = "Public subnet"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.lab-vcn.id
  route_table_id  = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list.id]
  dhcp_options_id = oci_core_virtual_network.lab-vcn.default_dhcp_options_id
  dns_label       = var.public_sn_dns_label
}
