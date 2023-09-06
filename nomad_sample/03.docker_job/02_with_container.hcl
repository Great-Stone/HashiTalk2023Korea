job "spring-boot-hello" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "dev"

  type = "service"

  constraint {
    attribute = "${attr.driver.java.version}"
    operator  = ">"
    value     = "17.0"
  }

  group "run-spring-boot-java" {

    count = 5

    scaling {
      enabled = true
      min     = 0
      max     = 10
    }

    network {
      port "boot" {}
    }

    task "java" {

      driver = "java"

      config {
        jar_path    = "local/hashitalks-0.0.1-SNAPSHOT.jar"
        jvm_options = ["-Xmx2048m", "-Xms256m"]
      }

      env {
        PORT  = "${NOMAD_PORT_boot}"
        COLOR = "skyblue"
      }

      artifact {
        source      = "https://github.com/Great-Stone/images/raw/master/build/hashitalks-0.0.1-SNAPSHOT.jar"
        destination = "local/"
      }

      resources {
        cpu        = 1000
        memory     = 1024
        memory_max = 2048
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

  group "run-spring-boot-docker" {

    count = 0

    scaling {
      enabled = true
      min     = 0
      max     = 10
    }

    network {
      port "boot" {
        to = 8080
      }
    }

    task "docker" {

      driver = "docker"

      config {
        image        = "hahohh/hashitalks-2023:0.0.1-${attr.cpu.arch}"
        ports = ["boot"]
      }

      env {
        COLOR = "skyblue"
        JAVA_TOOL_OPTIONS = "-Xms1024m -Xmx1024m"
      }

      resources {
        cpu        = 1000
        memory     = 1024
        memory_max = 1024
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
