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
      userName  = "sftp-admin"
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBuU0BhVp2beWX7U/DYZ/yKF0XYJTFD6BlPJPw0+GsPBSRi/PrhTxjpCG4FWmGNqoGhTI52B0GJGm+dYSit9CobPllvT4REif9EyWpzxD3T9B4jPweKFz6c25BgPGwMmQyl/yJrBRoDdGpwwYIsSUVcsUIPSlmvj52STtWRC+mkkfC4BJQWVjnGL1cnSkmYwhvbdXgVryRHBsTDOG07JBIaa/bp3kvg1SOqv5wKLrn5SC0dsXVEm2A7bbVDXIZOap2XV1NgGskG4csaG/b2WHZw7lOn1Sc0Fcc5cxmb6rqMTYDhRLcHRgFY6p2bcwJu898N7dk19gdgJDkHiUkGAbv",
      role      = "admin"
    },
    {
      userName  = "sftp-guest",
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBuU0BhVp2beWX7U/DYZ/yKF0XYJTFD6BlPJPw0+GsPBSRi/PrhTxjpCG4FWmGNqoGhTI52B0GJGm+dYSit9CobPllvT4REif9EyWpzxD3T9B4jPweKFz6c25BgPGwMmQyl/yJrBRoDdGpwwYIsSUVcsUIPSlmvj52STtWRC+mkkfC4BJQWVjnGL1cnSkmYwhvbdXgVryRHBsTDOG07JBIaa/bp3kvg1SOqv5wKLrn5SC0dsXVEm2A7bbVDXIZOap2XV1NgGskG4csaG/b2WHZw7lOn1Sc0Fcc5cxmb6rqMTYDhRLcHRgFY6p2bcwJu898N7dk19gdgJDkHiUkGAbv",
      role      = "guest"
    }
  ]
}
