resource "random_id" "id" {
  byte_length = 2
}

locals {
  name = "${var.name}-${random_id.id.hex}"

  ## This does not get updated on the VM after initial creation
  sftpUsers = [for user in var.sftpUsers : {
    userName  = user.userName,
    publicKey = user.publicKey != null ? user.publicKey : trimspace(tls_private_key.keys[user.userName].public_key_openssh),
    role      = user.role,
  }]

  service_account = var.service_account != null ? var.service_account : data.google_compute_default_service_account.compute_default_service_account.email
}

data "google_compute_default_service_account" "compute_default_service_account" {
  project = var.project
}

## This does not get updated on the VM after initial creation
resource "tls_private_key" "keys" {
  for_each  = { for user in var.sftpUsers : user.userName => user if user.publicKey == null }
  algorithm = "RSA"
  rsa_bits  = 2048
}

## This does not get updated on the VM after initial creation
resource "local_file" "private_key" {
  for_each        = { for user in var.sftpUsers : user.userName => user if user.publicKey == null }
  content         = tls_private_key.keys[each.key].private_key_pem
  filename        = "./${each.key}.key"
  file_permission = 600

  depends_on = [
    tls_private_key.keys
  ]
}

resource "google_compute_address" "address_external" {
  for_each     = { for k, v in var.interfaces : k => v if v.externalEnabled }
  name         = "${each.value.network}-${local.name}-ext"
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_address" "address_internal" {
  for_each     = var.interfaces
  name         = "${each.value.network}-${local.name}-int"
  project      = var.project
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = each.value.subnetwork
  address      = each.value.internalAddress
}

resource "google_compute_instance" "instance" {
  name                      = local.name
  project                   = var.project
  machine_type              = var.machine_type
  zone                      = var.zone
  deletion_protection       = var.deletion_protection
  can_ip_forward            = false
  allow_stopping_for_update = false
  tags                      = var.tags

  boot_disk {
    auto_delete = var.auto_delete_disk
    initialize_params {
      size  = var.disk_size
      type  = "pd-ssd"
      image = var.image
    }
  }

  service_account {
    email  = local.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      network_ip = network_interface.value.internalAddress
      subnetwork = network_interface.value.subnetwork
      dynamic "access_config" {
        for_each = network_interface.value.externalEnabled ? [1] : []
        content {
          nat_ip = [
            for address_external in google_compute_address.address_external : address_external.address
          if 0 < length(regexall(network_interface.value.network, address_external.name))][0]
        }
      }
    }
  }

  ## This will create a startup script for initial setup
  ## The startup script will configure SFTP access for users in var.sftpUsers
  metadata_startup_script = templatefile("${path.module}/metadata_startup_script.tftpl", { "sftpUsers" : local.sftpUsers })

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }

  depends_on = [
    tls_private_key.keys
  ]
}
