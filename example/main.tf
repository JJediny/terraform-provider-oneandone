provider "oneandone" {
}

resource "oneandone_vpn" "vpn" {
  datacenter = "GB"
  name = "test_vpn_01"
  description = "ttest descr"
}

resource "oneandone_public_ip" "ip" {
  "ip_type" = "IPV4"
  "reverse_dns" = "test.1and1.com"
  "datacenter" = "GB"
}

resource "oneandone_server" "server" {
  name = "test_server"
  description = "ttt"
  image = "ubuntu"
  datacenter = "GB"
  vcores = 1
  cores_per_processor = 1
  ram = 2
  ip = "${oneandone_public_ip.ip.ip_address}"
  ssh_key_path = "/path/to/private/key"
  hdds = [
    {
      disk_size = 60
      is_main = true
    }
  ]
  monitoring_policy_id = "${oneandone_monitoring_policy.mp.id}"
  firewall_policy_id = "${oneandone_firewall_policy.fw.id}"
  loadbalancer_id = "${oneandone_loadbalancer.lb.id}"

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]
  }
}

resource "oneandone_server" "server02" {
  name = "test_jg_2"
  description = "ttt"
  image = "ubuntu"
  datacenter = "GB"
  vcores = 1
  cores_per_processor = 1
  ram = 2
  ssh_key_path = "/path/to/private/key"
  hdds = [
    {
      disk_size = 60
      is_main = true
    }
  ]
  monitoring_policy_id = "${oneandone_monitoring_policy.mp.id}"
  firewall_policy_id = "${oneandone_firewall_policy.fw.id}"
  loadbalancer_id = "${oneandone_loadbalancer.lb.id}"

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]
  }
}

resource "oneandone_firewall_policy" "fw" {
  name = "test_fw_011"
  rules = [
    {
      "protocol" = "TCP"
      "port_from" = 80
      "port_to" = 80
      "source_ip" = "0.0.0.0"
    },
    {
      "protocol" = "ICMP"
      "source_ip" = "0.0.0.0"
    },
    {
      "protocol" = "TCP"
      "port_from" = 43
      "port_to" = 43
      "source_ip" = "0.0.0.0"
    },
    {
      "protocol" = "TCP"
      "port_from" = 22
      "port_to" = 22
      "source_ip" = "0.0.0.0"
    }
  ]
}

resource "oneandone_private_network" "pn" {
  name = "pn_test",
  description = "new stuff001"
  datacenter = "GB"
  network_address = "192.168.7.0"
  subnet_mask = "255.255.255.0"
  server_ids = [
    "${oneandone_server.server.id}",
    "${oneandone_server.server02.id}",
  ]
}

resource "oneandone_shared_storage" "storage" {
  name = "test_storage1"
  description = "1234"
  size = 50

  storage_servers = [
    {
      id = "${oneandone_server.server.id}"
      rights = "RW"
    },
    {
      id = "${oneandone_server.server02.id}"
      rights = "RW"
    }
  ]
}

resource "oneandone_monitoring_policy" "mp" {
  name = "test_mp"
  agent = true
  email = "email@address.com"

  thresholds = {
    cpu = {
      warning = {
        value = 50,
        alert = false
      }
      critical = {
        value = 66,
        alert = false
      }

    }
    ram = {
      warning = {
        value = 70,
        alert = true
      }
      critical = {
        value = 80,
        alert = true
      }
    },
    ram = {
      warning = {
        value = 85,
        alert = true
      }
      critical = {
        value = 95,
        alert = true
      }
    },
    disk = {
      warning = {
        value = 84,
        alert = true
      }
      critical = {
        value = 94,
        alert = true
      }
    },
    transfer = {
      warning = {
        value = 1000,
        alert = true
      }
      critical = {
        value = 2000,
        alert = true
      }
    },
    internal_ping = {
      warning = {
        value = 3000,
        alert = true
      }
      critical = {
        value = 4000,
        alert = true
      }
    }
  }
  ports = [
    {
      email_notification = true
      port = 443
      protocol = "TCP"
      alert_if = "NOT_RESPONDING"
    },
    {
      email_notification = false
      port = 80
      protocol = "TCP"
      alert_if = "NOT_RESPONDING"
    },
    {
      email_notification = true
      port = 21
      protocol = "TCP"
      alert_if = "NOT_RESPONDING"
    }
  ]

  processes = [
    {
      email_notification = false
      process = "httpdeamon"
      alert_if = "RUNNING"
    },
    {
      process = "iexplorer",
      alert_if = "NOT_RUNNING"
      email_notification = true
    }]
}

resource "oneandone_loadbalancer" "lb" {
  name = "test_lb"
  method = "ROUND_ROBIN"
  persistence = true
  persistence_time = 60
  health_check_test = "TCP"
  health_check_interval = 300
  datacenter = "GB"
  rules = [
    {
      protocol = "TCP"
      port_balancer = 8080
      port_server = 8089
      source_ip = "0.0.0.0"
    },
    {
      protocol = "TCP"
      port_balancer = 9090
      port_server = 9099
      source_ip = "0.0.0.0"
    }
  ]
}
