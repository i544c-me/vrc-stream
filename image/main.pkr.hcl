packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.2.6"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1.0"
    }
  }
}

locals {
  region   = "ap-northeast-1"
  project  = "vrc-stream-ubuntu-arm64"
  date     = formatdate("YYYYMMDDHHmm", timestamp())
  ami_name = "${local.project}-${local.date}"
}

source "amazon-ebs" "ubuntu" {
  ami_name              = local.ami_name
  instance_type         = "t4g.micro"
  region                = local.region
  ssh_username          = "ubuntu"
  force_delete_snapshot = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
}

build {
  name = local.ami_name
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    use_proxy     = false
  }
}