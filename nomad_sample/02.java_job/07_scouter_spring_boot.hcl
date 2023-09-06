variable "scouter_version" {
  default = "2.17.1"
}

locals {
  souter_release_url = "https://github.com/scouter-project/scouter/releases/download/v${var.scouter_version}/scouter-min-${var.scouter_version}.tar.gz"
}

job "spring-boot-hello" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "dev"

  type = "service"

  constraint {
    attribute = "${attr.driver.java.version}"
    operator  = ">"
    value     = "17.0"
  }

  group "run-spring-boot" {

    count = 10

    update {
      max_parallel = 5
    }

    network {
      port "boot" {}
    }

    task "java" {

      driver = "java"

      config {
        jar_path = "local/hashitalks-0.0.1-SNAPSHOT.jar"
        jvm_options = [
          "-Xmx1024m", "-Xms256m",
          "-javaagent:local/scouter/agent.java/scouter.agent.jar",
          "-Dscouter.config=local/conf/scouter.conf",
          "-Dobj_name=SpringBoot-${node.unique.name}-${NOMAD_SHORT_ALLOC_ID}-p${NOMAD_PORT_boot}",
          "--add-opens=java.base/java.lang=ALL-UNNAMED",
          "-Djdk.attach.allowAttachSelf=true"
        ]
      }

      env {
        PORT  = "${NOMAD_PORT_boot}"
        COLOR = "skyblue"
      }

      artifact {
        source      = "https://github.com/Great-Stone/images/raw/master/build/hashitalks-0.0.1-SNAPSHOT.jar"
        destination = "local/"
      }

      artifact {
        source      = local.souter_release_url
        destination = "/local"
      }

      template {
        data        = <<EOF
{{ range nomadService "scouter-collector" }}
net_collector_ip={{ .Address }}
net_collector_udp_port={{ .Port }}
net_collector_tcp_port={{ .Port }}
{{ end }}
hook_method_patterns=sample.mybiz.*Biz.*,sample.service.*Service.*,System.*.*,io.*.*
hook_method_access_public_enabled=true
hook_method_access_private_enabled=true
hook_method_access_protected_enabled=true
hook_method_access_none_enabled=true
profile_spring_controller_method_parameter_enabled=true
profile_http_parameter_enabled=true
profile_http_querystring_enabled=true
trace_http_client_ip_header_key=X-Forwarded-For
profile_spring_controller_method_parameter_enabled=false
hook_exception_class_patterns=my.exception.TypedException
profile_fullstack_hooked_exception_enabled=true
hook_exception_handler_method_patterns=my.AbstractAPIController.fallbackHandler,my.ApiExceptionLoggingFilter.handleNotFoundErrorResponse
hook_exception_hanlder_exclude_class_patterns=exception.BizException
EOF
        destination = "local/conf/scouter.conf"
      }

      resources {
        cpu        = 500
        memory     = 1024
      }

      service {
        provider = "nomad"

        name = "spring-boot"
        port = "boot"

        check {
          type     = "http"
          path     = "/hello"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
