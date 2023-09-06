# 디렉터리 생성
New-Item C:\nomad -ItemType Directory

# nomad.hcl 파일 이동
Move-Item -Path C:\Windows\Temp\nomad.hcl -Destination C:\nomad\nomad.hcl

# nomad.exe 파일 다운로드 및 압축 해제
$Url = "https://releases.hashicorp.com/nomad/1.6.1+ent/nomad_1.6.1_windows_amd64.zip"
$DownloadZipFile = "C:\Windows\Temp\" + $(Split-Path -Path $Url -Leaf)
$ExtractPath = "C:\nomad\"
Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile

$ExtractShell = New-Object -ComObject Shell.Application
$ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items()
$ExtractShell.NameSpace($ExtractPath).CopyHere($ExtractFiles)

New-NetFirewallRule -DisplayName "Allow TCP Ports 4646-4648 Inbound" -Direction Inbound -LocalPort 4646-4648 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow UDP Ports 4646-4648 Inbound" -Direction Inbound -LocalPort 4646-4648 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Ports 8080 Inbound" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Ports 20000-32000 Inbound" -Direction Inbound -LocalPort 20000-32000 -Protocol TCP -Action Allow

# 압축 해제 후 바로 실행하려는 경우 해당 exe 파일을 직접 실행
& "C:\nomad\nomad.exe" -version
& "C:\nomad\nomad.exe" config validate C:\nomad\nomad.hcl

# Nomad를 Windows 서비스로 등록
sc.exe create "Nomad" binPath="C:\nomad\nomad.exe agent -config=C:\nomad\nomad.hcl" start=auto
# sc.exe config "Nomad" obj=".\Administrator" password="SuperS3cr3t!!!!"
