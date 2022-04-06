output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
output "private_key" {
  value = nonsensitive(tls_private_key.public_private_key_pair.private_key_pem)
}
output "tenancy" {
  value = "${data.oci_identity_tenancy.tenancy}"
}
output "PublicIPs" {
  value = "${oci_core_instance.lab.*.public_ip}"
}
