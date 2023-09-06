variable "blue_count" {
  default = 20
}

variable "green_count" {
  default = 0
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

  group "run-spring-boot-blue" {

    count = var.blue_count

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

  group "run-spring-boot-green" {

    count = var.green_count

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
        COLOR = "limegreen"
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
}
