job "build_dockerfile_amd64" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "ops"

  type = "batch"

  constraint {
    attribute = "${attr.os.name}"
    value     = "ubuntu"
  }

  constraint {
    attribute = "${attr.cpu.arch}"
    value     = "amd64"
  }

  group "build" {

    count = 1

    task "build" {

      driver = "raw_exec"

      config {
        command    = "local/build.sh"
      }

      artifact {
        source      = "https://github.com/Great-Stone/images/raw/master/build/hashitalks-0.0.1-SNAPSHOT.jar"
        destination = "local/"
      }

      template {
        destination = "local/Dockerfile"
        data        = <<EOF
FROM openjdk:17-ea-slim
COPY hashitalks-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
      }

      template {
        destination = "local/build.sh"
        data        = <<EOF
#!/bin/bash
ls -rtl ./local
cd ./local
docker buildx build -t hahohh/hashitalks-2023:0.0.1-{{ env "attr.cpu.arch" }} .
{{ with nomadVar "nomad/jobs" }}
docker login --username={{ .DOCKER_USER }} --password={{ .DOCKER_PASS }}
{{ end }}
docker push hahohh/hashitalks-2023:0.0.1-{{ env "attr.cpu.arch" }}
EOF
      }

      resources {
        cpu        = 1000
        memory     = 512
      }
    }
  }
}
