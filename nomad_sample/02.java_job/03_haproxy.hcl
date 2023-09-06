job "haproxy" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "dev"

  type = "service"

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "haproxy" {
    count = 1

    network {
      port "http" {
        static = 8080
      }

      port "haproxy_ui" {
        static = 1936
      }
    }

    service {
      provider = "nomad"
      name     = "haproxy"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "haproxy" {
      driver = "docker"

      config {
        image        = "haproxy:2.4.24"
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      template {
        data = <<EOF
defaults
    mode http

frontend stats
    bind *:1936
    stats enable
    stats uri /
    stats refresh 10s
    no log

frontend http_front
    bind *:8080
    default_backend http_back

backend http_back
    balance roundrobin
    {{- range $index, $value := nomadService "spring-boot" }}
    server {{ $value.Name }}{{ $index }} {{ $value.Address }}:{{ $value.Port }} check
    {{- end }}
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cores  = 1
        memory = 512
      }
    }
  }
}
