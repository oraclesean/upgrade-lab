terraform {
  required_providers {
    oci = {
      source       = "hashicorp/oci"
    }
  }
  required_version = ">= 0.14"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
## Uncomment the following when running in Terraform CLI:
#  user_ocid        = var.user_ocid
#  fingerprint      = var.fingerprint
#  private_key_path = var.private_key_path

## Uncomment the following for OCI Cloud Shell:
#  auth             = "InstancePrincipal"
}

