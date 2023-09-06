// nomad namespace apply -description "scouter" scouter

variable "version" {
  default = "2.17.1"
}

locals {
  souter_release_url = "https://github.com/scouter-project/scouter/releases/download/v${var.version}/scouter-min-${var.version}.tar.gz"
}

job "scouter-host-agent" {
  datacenters = ["hashitalks-kr"]
  namespace   = "dev"

  type = "system"

  group "agent" {

    task "agent" {
      driver = "java"
      resources {
        cpu = 200
        memory = 512
      }
      artifact {
        source = local.souter_release_url
        destination = "/local"
      }
      env {
        NODE_NAME = "${node.unique.name}"
      }
      template {
data = <<EOF
obj_name={{ env "NODE_NAME" }}
{{ range nomadService "scouter-collector" }}
net_collector_ip={{ .Address }}
net_collector_udp_port={{ .Port }}
net_collector_tcp_port={{ .Port }}
{{ end }}
#cpu_warning_pct=80
#cpu_fatal_pct=85
#cpu_check_period_ms=60000
#cpu_fatal_history=3
#cpu_alert_interval_ms=300000
#disk_warning_pct=88
#disk_fatal_pct=92
EOF
        destination = "local/scouter/agent.host/conf/scouter.conf"
      }
      config {
        class_path = "local/scouter/agent.host/scouter.host.jar"
        class = "scouter.boot.Boot"
        args = ["local/lib"]
        jvm_options = [
          "-Dscouter.config=local/scouter/agent.host/conf/scouter.conf",
          "-Xmx200m"
        ]
      }
    }
  }
}
