job "02-install-apt-openjdk" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "ops"

  type = "sysbatch" # 배치 작업 유형

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  parameterized {
    payload       = "forbidden"
    meta_required = ["DesiredJavaVersion"]
  }

  group "install-group" {

    task "install-java-task" {
      driver = "raw_exec" # 외부 스크립트를 실행

      config {
        command = "local/install_openjdk.sh"
      }

      env {
        JAVA_VERSION = "${NOMAD_META_DesiredJavaVersion}"
      }

      template {
        destination = "local/install_openjdk.sh"
        data        = <<EOF
#!/bin/bash
apt-get update
apt-get install -y openjdk-$JAVA_VERSION-jdk
EOF
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
