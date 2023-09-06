job "01-install-choco-microsoft-openjdk" {
  datacenters = ["hashitalks-kr"] # 사용할 데이터 센터 이름으로 수정
  namespace   = "ops"

  type = "sysbatch" # 배치 작업 유형

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  parameterized {
    payload       = "forbidden"
    meta_required = ["DesiredJavaVersion"]
  }

  group "install-group" {

    task "choco-install" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "powershell.exe"
        args = [
          "-File",
          "local/installChoco.ps1"
        ]
        // args    = [
        //   "-Command",
        //   "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        // ]
      }

      template {
        data = <<EOH
# 관리자 권한 확인
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    throw "You must run this script as an Administrator. Right-click and select 'Run as Administrator'."
}

# 스크립트 실행 정책 설정
Set-ExecutionPolicy Bypass -Scope Process -Force

# Chocolatey 설치
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# 환경 변수 재로드 (현재 PowerShell 세션에 대해)
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        EOH

        destination = "local/installChoco.ps1"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }

    task "install-java-task" {
      driver = "raw_exec" # 외부 스크립트를 실행

      config {
        command = "powershell.exe"
        args = [
          "-Command",
          "C:\\ProgramData\\chocolatey\\bin\\choco install -y microsoft-openjdk${NOMAD_META_DesiredJavaVersion} --force"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }

    task "nomad-restart" {
      lifecycle {
        hook = "poststop"
      }

      driver = "raw_exec"

      config {
        command = "powershell.exe"
        args    = ["Restart-Service", "-Name", "Nomad"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
