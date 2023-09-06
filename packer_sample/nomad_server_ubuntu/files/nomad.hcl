// name = "HOST_NAME"
datacenter = "hashitalks-kr"
data_dir = "/var/lib/nomad"

bind_addr = "0.0.0.0"

advertise {
//  http = "{{ GetInterfaceIP \"ens5\" }}"
  rpc  = "{{ GetInterfaceIP \"ens5\" }}"
  serf = "{{ GetInterfaceIP \"ens5\" }}"
}

acl {
  enabled = true
}

ui {
  enabled = true

  // consul {
  //   ui_url = "http://192.168.60.11:8500/ui"
  // }
  
  // vault {
  //   ui_url = "http://192.168.60.11:8200/ui"
  // }

  label {
    text             = "HashiTalks:대한민국"
    background_color = "#302d23"
    text_color       = "#ffffff"
  }
}

// consul {
//   address = "127.0.0.1:8500"
// }

server {
  enabled          = true
  bootstrap_expect = 3
  encrypt = "H6NAbsGpPXKJIww9ak32DAV/kKAm7vh9awq0fTtUou8="
  // license_path = "/etc/nomad.d/nomad.hclic"
  server_join {
    retry_join = ["provider=aws region=ap-northeast-2 tag_key=nomad tag_value=server addr_type=private_v4"] // Need AWS Profile
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    gc {
      image = false
    }
  }
}

telemetry {
  collection_interval = "1s",
  prometheus_metrics = true,
  publish_allocation_metrics = true,
  publish_node_metrics = true
}
