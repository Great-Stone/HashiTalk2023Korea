variable "version" {
  default = "2.17.1"
}

job "scouter-collector" {
  datacenters = ["hashitalks-kr"]
  namespace   = "dev"

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  type = "service"

  group "collector" {
    count = 1

    scaling {
      enabled = false
      min     = 1
      max     = 1
    }

    network {
      mode = "host"
      port "tcp1" {
        to = 6180
      }
      port "tcp2" {
        to = 6188
      }
      port "tcp3" {
        to     = 6100
        static = 6100
      }
    }

    task "collector" {
      driver = "docker"
      resources {
        cpu    = 1000
        memory = 1024
      }

      env {
        SC_SERVER_ID                 = "SCCOUTER-COLLECTOR"
        NET_HTTP_SERVER_ENABLED      = "true"
        NET_HTTP_API_SWAGGER_ENABLED = "true"
        NET_HTTP_API_ENABLED         = "true"
        MGR_PURGE_PROFILE_KEEP_DAYS  = "2"
        MGR_PURGE_XLOG_KEEP_DAYS     = "5"
        MGR_PURGE_COUNTER_KEEP_DAYS  = "15"
        JAVA_OPT                     = "-Xms1024m -Xmx1024m"
      }

      config {
        image = "scouterapm/scouter-server:${var.version}"
        ports = ["tcp1", "tcp2", "tcp3"]
      }

      service {
        name     = "scouter-collector"
        provider = "nomad"

        port = "tcp3"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
          port     = "tcp3"
        }
      }
    }
  }
}
