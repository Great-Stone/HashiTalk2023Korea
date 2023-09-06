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

///////////////
// Windows
data "amazon-ami" "windows-2022" {
  region = var.region
  filters = {
    name = "Windows_Server-2022-English-Full-*"
  }
  most_recent = true
  owners      = ["amazon"]
}

source "amazon-ebs" "windows-2022" {
  region        = var.region
  source_ami    = data.amazon-ami.windows-2022.id
  instance_type = "t3.xlarge"
  communicator  = "winrm"
  ami_name      = "packer_windows_2022_nomad_client_{{timestamp}}_v${var.version}"

  user_data_file = "./bootstrap_win.txt"
  winrm_password = "SuperS3cr3t!!!!"
  winrm_username = "Administrator"
}


///////////////////////////////////////////////////////////////////////////
build {
  hcp_packer_registry {
    bucket_name = "windows-nomad-client"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "owner"   = "gs"
      "os"      = "Windows"
      "nomad"   = "client"
      "version" = var.version
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = ["source.amazon-ebs.windows-2022"]

  provisioner "powershell" {
    environment_vars = ["DEVOPS_LIFE_IMPROVER=PACKER"]
    inline           = [
      "Write-Host \"HELLO NEW USER; WELCOME TO $Env:DEVOPS_LIFE_IMPROVER\"", "Write-Host \"You need to use backtick escapes when using\"", "Write-Host \"characters such as DOLLAR`$ directly in a command\"", "Write-Host \"or in your own scripts.\""
    ]
  }

  //////// To Slow
  // provisioner "file" {
  //   source      = "./files/nomad.exe"
  //   destination = "C:\\temp\\nomad.exe"
  // }

  provisioner "file" {
    source      = "./files/nomad.hcl"
    destination = "C:\\Windows\\Temp\\nomad.hcl"
  }

  provisioner "powershell" {
    environment_vars = ["VAR1=A$Dollar", "VAR2=A`Backtick", "VAR3=A'SingleQuote", "VAR4=A\"DoubleQuote"]
    script           = "./sample_script.ps1"
  }
}
