module "sftp_appliance" {
  source  = "r-teller/appliance-sftp/google"
  version = "~> 0.1.0"

  project = "rteller-demo-host-aaaa"
  region  = "us-central1"
  zone    = "us-central1-a"

  tags = ["sftp-appliance"]

  interfaces = {
    0 = {
      externalEnabled = true,
      network         = "test-cases-vpc-foobar",
      subnetwork      = "projects/rteller-demo-host-aaaa/regions/us-central1/subnetworks/foobar-usc1-primary-10-2-3-0-24",
      internalAddress = null,
    }
  }

  ## This does not get updated on the VM after initial creation
  ## Make sure this user does not conflict with users that would be created through IAP
  sftpUsers = [
    {
      userName  = "sftp-admin",
      publicKey = null,
      role      = "admin",
    },
    {
      userName  = "sftp-guest",
      publicKey = null,
      role      = "guest",
    }
  ]
}