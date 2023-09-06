// packer init -upgrade .
// packer build .

packer {
  required_plugins {
    amazon = {
      version = "~> 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

data "amazon-ami" "ubuntu-focal" {
  region = var.region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-focal" {
  region        = var.region
  source_ami    = data.amazon-ami.ubuntu-focal.id
  instance_type = "t3.small"
  ssh_username  = "ubuntu"
  ami_name      = "packer_ubuntu_focal_nomad_server_{{timestamp}}_v${var.version}"
}

build {
  hcp_packer_registry {
    bucket_name = "ubuntu-nomad-server"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "owner"   = "gs"
      "os"      = "Ubuntu"
      "nomad"   = "server"
      "version" = var.version
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
  sources = [
    "source.amazon-ebs.ubuntu-focal"
  ]

  provisioner "file" {
    source      = "./files/"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "echo Connected client at \"${build.User}@${build.Host}:${build.Port}\"",
      /* APT UPDATE */
      "echo ====== APT UPDATE ======",
      "sudo apt-get update && sudo apt-get -y upgrade",
      "sudo apt-get autoremove",
      /* Nomad */
      "echo ====== Nomad ======",
      "sudo apt-get update && sudo apt-get install -y gnupg software-properties-common",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt-get update && sudo apt-get install nomad -y",
      "sudo mv /tmp/nomad.* /etc/nomad.d/",
      "sudo chown nomad:nomad /etc/nomad.d/nomad.*",
      "nomad version",
      "sudo systemctl enable nomad",
    ]
  }
}
