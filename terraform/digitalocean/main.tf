terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.3.0"
    }
  }
}

# set Environment variable TF_VAR_digitalocean_access_key.
# use digital ocean access token.
variable "digitalocean_access_key" {}

data "template_file" "user_data" {
  template = file("../../provision.sh")
  vars = {
    ORACLE_PASSWORD = ""
  }
}

provider "digitalocean" {
  token = var.digitalocean_access_key
}

resource "digitalocean_project" "example" {
  name        = "terraform_project"
  description = "orcle database application"
  purpose     = "Oracle Database"
  environment = "Development"
}

resource "digitalocean_droplet" "oracle" {
  image  = "fedora-33-x64"
  name   = "oracle-1"
  # use resion slug
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  # digital ocean stored ssh_key fingerprint
  ssh_keys = ["61:f6:88:ab:f7:c2:53:df:39:bb:71:10:8c:91:1e:b1"]

  # user_data = file("../../provision.sh")

  user_data = data.template_file.user_data.rendered
}