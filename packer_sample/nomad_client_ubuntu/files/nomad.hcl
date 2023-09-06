// name = "HOST_NAME"
datacenter = "hashitalks-kr"
data_dir = "/var/lib/nomad"

bind_addr = "0.0.0.0"

advertise {
  http = "{{ GetInterfaceIP \"ens5\" }}"
  rpc  = "{{ GetInterfaceIP \"ens5\" }}"
  serf = "{{ GetInterfaceIP \"ens5\" }}"
}

client {
  enabled = true
  server_join {
    retry_join = ["provider=aws region=ap-northeast-2 tag_key=nomad tag_value=server addr_type=private_v4"]
  }
  network_interface = "ens5"
  meta {
    "subject" = "nomad-demo"
  }
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    // auth {
    //   config = "/etc/nomad.d/docker-auth.json"
    // }
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
