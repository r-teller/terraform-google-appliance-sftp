variable "name" {
  type    = string
  default = "sftp-appliance"
}

variable "service_account" {
  type    = string
  default = null
}

variable "scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
  ]
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "image" {
  type    = string
  default = "debian-cloud/debian-10"
}

variable "disk_size" {
  type    = number
  default = 200
}

variable "auto_delete_disk" {
  type    = bool
  default = true
}

variable "sftpUsers" {
  type = list(object({
    userName  = string,
    publicKey = string,
    role      = string,
  }))

  validation {
    condition     = !(can(index([for user in var.sftpUsers : contains(["admin", "guest"], user.role)], false)))
    error_message = "One or more strings in var.sftpUsers.role is not supported, supported strings are [admin, guest]."
  }
}

variable "interfaces" {
  type = map(object({
    externalEnabled = bool,
    network         = string,
    subnetwork      = string,
    internalAddress = string,
  }))

  validation {
    condition     = length(var.interfaces) >= 1 && length(var.interfaces) <= 8
    error_message = "Var.interfaces must contain between 1 and 8 interfaces."
  }
  validation {
    # Checks to see if any of the keys in the interface map are non-numbers
    condition     = alltrue([for key in keys(var.interfaces) : contains(range(0, length(var.interfaces)), tonumber(key))])
    error_message = "One or more keys in var.interfaces is outside of the allocated interface range."
  }
  validation {
    # Checks to make sure the internal address is a properly formated IP == 192.168.0.1
    condition     = alltrue([for interface in var.interfaces : can(cidrhost("${interface.internalAddress}/32", 0)) || interface.internalAddress == null])
    error_message = "One or more internalAddresses in var.interfaces is not properly formatted. Expected format is a specific IP Addresses or null."
  }
}
