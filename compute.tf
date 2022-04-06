data "template_file" "cloud-init" {
  template = file("${path.module}/scripts/cloud-init.yaml")
}

data "template_file" "lab-docker" {
  template = file("${path.module}/scripts/setup-docker.sh")

  vars = {
    lab_version = var.lab_version
  }
}

resource "oci_core_instance" "lab" {
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = local.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.public_key_openssh : join("\n", [var.public_ssh_key, tls_private_key.public_private_key_pair.public_key_openssh])
    user_data           = base64encode(data.template_file.cloud-init.rendered)
  }

  shape_config {
    ocpus               = var.ocpu_count
    memory_in_gbs       = var.instance_memory
  }
}

data "oci_core_vnic_attachments" "lab_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain_name
  instance_id         = oci_core_instance.lab.id
}

data "oci_core_vnic" "lab_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.lab_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "lab_private_ips1" {
  vnic_id = data.oci_core_vnic.lab_vnic1.id
}

# Create storage
resource "oci_core_volume" "lab_volume" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain_name
  display_name        = var.block_volume_name
  size_in_gbs         = var.block_volume_size
}

# Attach block volume
resource "oci_core_volume_attachment" "createAttachment" {
    attachment_type = "iscsi" #"paravirtualized"
    instance_id     = oci_core_instance.lab.id
    volume_id       = oci_core_volume.lab_volume.id
    device          = var.bv_attachment_name
    display_name    = var.bv_attachment_display_name
 
    connection {
      type        = "ssh"
      host        = data.oci_core_vnic.lab_vnic1.public_ip_address
      agent       = false
      timeout     = "3m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    # register and connect the iSCSI block volume
    provisioner "remote-exec" {
      inline = [
        "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
        "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
        "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
      ]
    }

    # initialize partition and file system and mount the partition
    provisioner "remote-exec" {
      inline = [
        "set -x",
        "export DEVICE_ID=$(ls /dev/disk/by-path/ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-*)",
        "export HAS_PARTITION=$(sudo partprobe -d -s $${DEVICE_ID} | wc -l)",
        "if [ $HAS_PARTITION -eq 0 ] ; then",
        "  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk $${DEVICE_ID}",
        "  while [[ ! -e $${DEVICE_ID}-part1 ]] ; do sleep 1; done",
        "  sudo mkfs.xfs $${DEVICE_ID}-part1",
        "fi",
        "sudo mkdir -p /oradata",
        "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value $${DEVICE_ID}-part1)",
        "echo 'UUID='$${UUID}' /oradata xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
        "sudo mount -a",
      ]
    }
}

resource "null_resource" "lab_provisioner" {
  depends_on = [oci_core_instance.lab]

  provisioner "file" {
    content     = data.template_file.lab-docker.rendered
    destination = "/home/opc/setup-docker.sh"

    connection {
      type        = "ssh"
      host        = data.oci_core_vnic.lab_vnic1.public_ip_address
      agent       = false
      timeout     = "3m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = data.oci_core_vnic.lab_vnic1.public_ip_address
      agent       = false
      timeout     = "30m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    
    inline = [
      "while [ ! -f /tmp/cloud-init-complete ]; do sleep 30; done",
      "chmod u+x /home/opc/setup-docker.sh",
      "/home/opc/setup-docker.sh"
    ]
  }
}
