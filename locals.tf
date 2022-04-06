locals {
  availability_domain_name   = data.oci_identity_availability_domains.ad_list.availability_domains.0.name
  instance_shape             = var.instance_shape
  compute_flexible_shapes    = ["VM.Standard.E3.Flex","VM.Standard.E4.Flex"]
#  compute_flexible_shapes    = ["VM.Standard.E2.1.Micro","VM.Standard.E3.Flex","VM.Standard.E4.Flex"]
  is_flexible_instance_shape = contains(local.compute_flexible_shapes, local.instance_shape)
}
