resource "google_compute_address" "address_external" {
  for_each     = { for k, v in var.interfaces : k => v if v.externalEnabled }
  name         = "${each.value.network}-${var.sftp_appliance_name}-ext"
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}


resource "google_compute_address" "address_internal" {
  for_each     = var.interfaces
  name         = "${each.value.network}-${var.sftp_appliance_name}-int"
  project      = var.project
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = each.value.subnetwork
  address      = each.value.internalAddress
}

resource "google_compute_instance" "instnace" {
  name                      = var.sftp_appliance_name
  project                   = var.project
  machine_type              = var.machine_type
  zone                      = var.zone
  deletion_protection       = var.deletion_protection
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = var.tags

  metadata = {

  }

  service_account {
    email  = local.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      network_ip = network_interface.value.internalAddress
      subnetwork = data.google_compute_subnetwork.subnetwork[network_interface.key].id
      dynamic "access_config" {
        for_each = network_interface.value.externalEnabled ? [1] : []
        content {
          nat_ip = [
            for external_address in google_compute_address.external_address : external_address.address
          if 0 < length(regexall(network_interface.value.network, external_address.name))][0]
        }
      }
    }
  }

  boot_disk {
    initialize_params {
      image = var.image
      type  = "pd-ssd"
    }
  }

  depends_on = [
    google_storage_bucket_object.init_cfg,
    google_storage_bucket_object.bootstrap,
  ]
}