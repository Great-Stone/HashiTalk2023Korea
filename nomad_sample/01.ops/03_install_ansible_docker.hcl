job "03-install-ansible-docker" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "ops"

  type = "sysbatch" # 배치 작업 유형

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  parameterized {
    payload = "forbidden"
  }

  group "install- group" {

    task "install-ansible-task" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "raw_exec" # 외부 스크립트를 실행

      config {
        command = "local/install_ansible.sh"
      }

      template {
        destination = "local/install_ansible.sh"
        data        = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ansible
EOF
      }
    }

    task "install-docker-task" {
      driver = "raw_exec" # 외부 스크립트를 실행

      config {
        command = "ansible-playbook"
        args = [
          "-vvvv",
          "local/playbook.yml"
        ]
      }

      env {
        JAVA_VERSION = "${NOMAD_META_DesiredJavaVersion}"
      }

      template {
        destination = "local/playbook.yml"
        data        = <<EOF
---
- hosts:
    - localhost
  become: yes
  tasks:
    - name: Install aptitude
      apt:
        name: aptitude
        state: latest
        update_cache: true

    - name: Install required packages
      apt:
        pkg:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
          - python3-pip
          - virtualenv
          - python3-setuptools
          - git
        state: latest
        update_cache: true

    - name: Add Docker GPG apt Key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch={{ env "attr.cpu.arch" }}] https://download.docker.com/linux/ubuntu {{"{{"}} ansible_lsb.codename {{"}}"}} stable"
        state: present
        update_cache: true

    - name: Update the apt package index
      apt:
        update_cache: true

    - name: Install Docker CE
      apt:
        name: docker-ce
        state: latest

    - name: Install Docker CE etc.
      apt:
        name:
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present

    - name: Ensure Docker starts on boot
      service:
        name: docker
        enabled: true
        state: started
EOF
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
