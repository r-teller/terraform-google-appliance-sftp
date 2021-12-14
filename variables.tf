variable "service_account" {
  type    = string
  default = null
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

variable "tags" {
  type    = list(string)
  default = []
}

variable "machine_type" {
  type    = string
  default = "e2-standard-8"
}

variable "image" {
  // Hourly Licenses
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle1-909"
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle2-909"

  // BYOL License  
  default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-909"
}