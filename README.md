## Table of Contents
* [Getting Started](#getting-started)
* [Introduction](#introduction)
* [Install Terraform](#install-terraform)
    * [Add the Terraform Directory to the PATH](#add-the-terraform-directory-to-the-path)
    * [Verify the Terraform Installation](#verify-the-terraform-installation)
* [Install the Plug-In](#install-the-plug-In)
* [Usage](#usage)
    * [Credentials](#credentials)
    * [Basic Fuctions](#basic-functions)
    * [Advanced Example](#advanced-example)
* [1&amp;1 Terraform Resources](#resources)
    * [Server](#server)
    * [Public IP](#public-ip)
    * [Shared Storage](#shared-storage)
    * [Private Network](#private-network)
    * [Firewall Policy](#firewall-policy)
    * [VPN](#vpn)
    * [Monitoring Policy](#monitoring-policy)
    * [Load Balancer](#load-balancer)


## Getting Started

Before you begin you will need to have signed up for a 1&amp;1 account. The credentials you create during sign-up will be used to authenticate against the API.

## Introduction

This is a plug-in for [Terraform](http://terraform.io/). Terraform enables you to safely and predictably create, change, and improve production infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

## Install Terraform

Terraform must first be installed on the machine where you plan to run it. Terraform is distributed as a binary package for various platforms and architectures.

To install Terraform, download [the appropriate package for your system](https://www.terraform.io/downloads.html). Terraform is packaged as a zip archive.

After downloading, unzip the package into a directory where Terraform will be installed. (Example: `~/terraform` or `c:\terraform`)

### Add the Terraform Directory to the PATH

Note: The adjustments to the PATH environment variable as outlined below are temporary. There are numerous examples available on the internet describing how to make permanent changes to environment variables for each particular operating system. 

If you prefer not to change the PATH, you can invoke Terraform directly by going to the directory and using the command `./terraform`, or from anywhere using the full path such as `./home/jdoe/terraform`.

To add the Terraform directory to your PATH:

**Linux** 

If you plan to run Terraform in a shell on Linux and placed the binary in the `/home/[username]/terraform/` directory, you would use the command:

    PATH=$PATH:/home/[username]/terraform

**Mac OSX**

If you plan to run Terraform in a shell on a Mac and placed the binary in the `/Users/[username]/terraform/` directory, you would use the command:

    PATH=$PATH:/Users/[YOUR-USER-NAME]/terraform

**Windows** 

If you plan to run `terraform.exe` in PowerShell on Windows and placed the binary in `c:\terraform` directory, you would first find the existing value of PATH:

    echo $env:Path


If it ends with a ;, then run:


    $env:Path += "c:\terraform"


If it does NOT end with a ;, then run:


    $env:Path += ";c:\terraform"

### Verify the Terraform Installation

After installing Terraform, verify the installation by executing `terraform` or `terraform.exe`. You should see the default "usage" output similar to this:

```
$ terraform
usage: terraform [--version] [--help] <command> [<args>]

Available commands are:
    apply       Builds or changes infrastructure
    destroy     Destroy Terraform-managed infrastructure
    get         Download and install modules for the configuration
    graph       Create a visual graph of Terraform resources
    init        Initializes Terraform configuration from a module
    output      Read an output from a state file
    plan        Generate and show an execution plan
    push        Upload this Terraform module to Atlas to run
    refresh     Update local state file against real resources
    remote      Configure remote state storage
    show        Inspect Terraform state or plan
    taint       Manually mark a resource for recreation
    validate    Validates the Terraform files
    version     Prints the Terraform version
```


## Install the Plug-In

Download the desired release archive from [the 1&amp;1 Terraform Provider Releases](https://github.com/1and1/terraform-provider-oneandone/releases). Extract the binary from the archive and place it in the same location you used for the Terraform binary in the previous step. It should have the name `terraform-provider-oneandone` or `terraform-provider-oneandone.exe`.

### Build the Plug-In from Source

The build process requires that the [GO](https://golang.org/) language be installed and configured on your system.

Once you have GO installed and working, then retrieve the Terraform 1&amp;1 provider source code using the following command:

    go get github.com/1and1/terraform-provider-oneandone


Then change to the project directory and run `make install`:

    cd $GOPATH/github.com/1and1/terraform-provider-oneandone

    make install

The resulting binary can be copied to the same directory you installed Terraform in.


## Usage

We will go through a basic example of provisioning a server inside a Virtual Data Center after providing Terraform with our credentials.

### Credentials

You can provide your credentials using the `ONEANDONE_TOKEN` environment variables, representing your 1&amp;1 token, respectively.

    $ export ONEANDONE_TOKEN="oneandone-token"

Or you can include your credentials inside the `main.tf` file:


    provider "oneandone" {
        token = "oneandone-token"
        retries = 100
    }

Note: `retries` describes the number of retries while waiting for a resource to be provisioned. The default value is 50.

### Basic Functions

Terraform uses text files to describe infrastructure and to set variables. These text files are called "Terraform configurations," and end in `.tf`.

First create a folder to hold your `.tf` files and change your current directory to the newly created one:

    $xslt
    mkdir example
    cd example

Create the `main.tf` file, and copy the following into `main.tf`:

```
$xslt
provider "oneandone" {
    token = "oneandone-token"
}

resource "oneandone_server" "server" {
  name = "Example"
  description = "Terraform 1and1 tutorial"
  image = "ubuntu"
  datacenter = "GB"
  vcores = 1
  cores_per_processor = 1
  ram = 2
  ssh_key_path = "/path/to/prvate/ssh_key"
  hdds = [
    {
      disk_size = 60
      is_main = true
    }
  ]
  
  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]
  }
}
```

This example will create a single 1&amp;1 Server, and install `nginx` on it. Section `provisoner` uses `remote-exec` provisioner to install `nginx`.    
To confirm that the `.tf` file uses correct syntax the best way is to run:

```$xslt
terraform plan
```

Which should produce output similar to this:

```$xslt
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.


The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ oneandone_server.server
    cores_per_processor: "1"
    datacenter:          "GB"
    description:         "Terraform 1and1 tutorial"
    hdds.#:              "1"
    hdds.0.disk_size:    "60"
    hdds.0.id:           "<computed>"
    hdds.0.is_main:      "true"
    image:               "ubuntu"
    ips.#:               "<computed>"
    name:                "Example"
    ram:                 "2"
    ssh_key_path:        "/path/to/prvate/ssh_key"
    vcores:              "1"
```
If Terraform configuration is not correct you will be seeing something like this:

```$xslt
Errors:

  * oneandone_server.server: "image": required field is not set
```

The next step is to create infrastructure defined in `main.tf`.

```$xslt
terraform apply
```

Which should produce output similar to this (truncated):

```$xslt
oneandone_server.server: Creating...
  cores_per_processor: "" => "1"
  datacenter:          "" => "GB"
  description:         "" => "Terraform 1and1 tutorial"
  hdds.#:              "0" => "1"
  hdds.0.disk_size:    "" => "60"
  hdds.0.id:           "" => "<computed>"
  hdds.0.is_main:      "" => "true"
  image:               "" => "ubuntu"
  ips.#:               "" => "<computed>"
  name:                "" => "1and1 Example"
  ram:                 "" => "2"
  ssh_key_path:        "" => "/Users/jasmingacic/.ssh/id_rsa"
  vcores:              "" => "1"
oneandone_server.server: Still creating... (10s elapsed)
...
oneandone_server.server: Still creating... (4m10s elapsed)
oneandone_server.server: Provisioning with 'remote-exec'...
oneandone_server.server (remote-exec): Connecting to remote host via SSH...
oneandone_server.server (remote-exec):   Host: 77.68.14.77
oneandone_server.server (remote-exec):   User: root
oneandone_server.server (remote-exec):   Password: true
oneandone_server.server (remote-exec):   Private key: true
oneandone_server.server (remote-exec):   SSH Agent: true
oneandone_server.server (remote-exec): Connected!
oneandone_server.server (remote-exec): 0% [Working]
oneandone_server.server (remote-exec): Hit http://security.ubuntu.com trusty-security InRelease
...
oneandone_server.server (remote-exec): Setting up nginx-core (1.4.6-1ubuntu3.7) ...
oneandone_server.server (remote-exec): Setting up nginx (1.4.6-1ubuntu3.7) ...
oneandone_server.server (remote-exec): Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
oneandone_server.server: Creation complete

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

If terraform has failed to created desired infrastructure you can check for errors in `crash.log` file. If you want to retry simply remote `terraform.tfstate` and run `apply` again. 

If you want to get detailed "DEBUG" onscreen information while running 1&amp;1 provider plugin output, you can set the `TF_LOG` environment variable.

From a shell on Linux or Mac, this can be done using export:

```
export TF_LOG=1
```

In PowerShell on Windows:

```
$env:TF_LOG = 1
```

After the infrastructure has been provisoned and you wish to update newly created server simply edit `main.tf`. For example to rename the server do this:
 
```$xslt
resource "oneandone_server" "server" {
  name = "1and1 Example renamed"
  description = "Terraform 1and1 tutorial"
  image = "ubuntu"
  datacenter = "GB"
  vcores = 1
  cores_per_processor = 1
  ram = 2
  ssh_key_path = "/path/to/prvate/ssh_key"
  hdds = [
    {
      disk_size = 60
      is_main = true
    }
  ]

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install nginx",
    ]
  }
}
```

```$xslt
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

oneandone_server.server: Refreshing state... (ID: 30E10107507669DF1F27A0336D1EB672)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

~ oneandone_server.server
    name:     "1and1 Example" => "1and1 Example renamed"


Plan: 0 to add, 1 to change, 0 to destroy.
```

To remove the infrastructure you just created, run:

```$xslt
$terraform destroy

Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```
### Advanced Example

A more advanced example is located from the [repository](https://github.com/1and1/terraform-provider-oneandone/tree/master/example).
Download `main.tf`, and after you customized it to your liking run:

```$xslt
$terraform plan
```

Review the output and then apply the configuration by running:

```$xslt
$terraform apply
```

## 1&amp;1 Terraform Resources <a name="resources"></a>

### Server

#### Example Server

```$xslt
resource "oneandone_server" "server" {
  name = "test_server"
  description = "test description"
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
}
```
#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the server. |
| description | No | string | Description of the server |
| image | Yes | String |  The name of a desired image to be provisioned with the server |
| vcores | Yes | integer | Number of virtual cores. |
| cores_per_processor | yes | int | Number of cores per processor |
| ram | Yes | float | Size of ram. |
| ssh_key_path | No | string | Path to private ssh key |
| password | No | String | Desired password. |
| datacenter | No | String | Location of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |
| ip | No | String | IP address for the server |
| hdds | Yes | Collection | List of HDDs. One HDD must be main. |
| *disk_size | Yes | integer | The size of HDD  |
| *is_main | No | Boolean | Indicates if HDD is to be used as main hard disk of the server  |
| firewall_policy_id | No | String | ID of firewall policy |
| monitoring_policy_id | No | String | ID of monitoring policy |
| loadbalancer_id | No | String | ID of the load balancer |

### Public IP

#### Example Public IP

```$xslt
resource "oneandone_public_ip" "ip" {
  "ip_type" = "IPV4"
  "reverse_dns" = "test.1and1.com"
  "datacenter" = "GB"
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| ip_type | Yes | string | IPV4 or IPV6 |
| reveres_dns| Yes | string |  |
| datacenter_id | No | String |  TLocation of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |

### Shared Storage

#### Example Shared Storage

```$xslt
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
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the private network. |
| description | No | string | Description for the private network |
| size | Yes | String |  Sized of the shared storage |
| datacenter | No | String | Location of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |
| storage_servers | No | Collection |  List of servers that will have access to the stored storage |
| id | Yes | String |  ID of the server |
| rights | Yes | String | Access rights to be assigned to the server ["RW","R"] |

### Private Network

#### Example Private Network

```$xslt
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
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the private network. |
| description | No | string | Description for the private network |
| datacenter | No | String |  Location of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |
| network_address| No | String |  Network address for the private network |
| subnet_mask | No | String |  Subnet mask for the private network |
| server_ids | No | Collection |  List of servers that are to be associated with the private network |

### Firewall Policy

#### Example Firewall Policy

```$xslt
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
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the VPN. |
| description | No | string | Description for the VPN |
| rules | Yes | Collection |  Collection of firewall policy rules |
| protocol | Yes | String |  The protocol for the rule ["TCP", "UDP", "TCP/UDP", "ICMP", "IPSEC"]|
| port_from | No | String |  Defines the start range of the allowed port |
| port_to | No | String |  Defines the end range of the allowed port |
| source_ip | No | String |  Only traffic directed to the respective IP address |

### VPN

##### Example VPN

```$xslt
resource "oneandone_vpn" "vpn" {
  datacenter = "GB"
  name = "test_vpn_01"
  description = "ttest descr"
}
```

#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the VPN. |
| description | No | string | Description for the VPN |
| datacenter | No | String |  Location of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |
| download_path | No | String |  Location where VPN configuration will be downloaded. If "download_path" is not provided VPN config will be downloaded where terraform is executed. |

### Monitoring Policy

#### Example Monitoring Policy

```$xslt
resource "oneandone_monitoring_policy" "mp" {
  name = "test_mp"
  agent = true
  email = "jasmin@stackpointcloud.com"

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
```
#### Argument Reference

| Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | string | The name of the VPN. |
| description | No | string | Description for the VPN |
| email | No | String |  Email address to which notifications monitoring system will send ] |
| agent| Yes | Boolean |  Indicates which monitoring type will be used. True - this monitoring type, you must install an agent on the server.  False - monitor a server without installing an agent, then you cannot retrieve information such as free hard disk space or ongoing process.|
| thresholds | Yes | Collection | Collection of thresholds for different types of resources  |
| *cpu | Yes | Type |  CPU thresholds |
| **warning | Yes | Type |  Warning alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| **critical | Yes | Type |  Critical alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| *ram | Yes | Type |  RAM threshold |
| **warning | Yes | Type |  Warning alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| **critical | Yes | Type |  Critical alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| *disk | Yes | Type |  Hard Disk threshold |
| **warning | Yes | Type |  Warning alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| **critical | Yes | Type |  Critical alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| *transfer | Yes | Type |  Data transfer threshold |
| **warning | Yes | Type |  Warning alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| **critical | Yes | Type |  Critical alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| *internal_ping | Yes | type |  Ping threshold |
| **warning | Yes | Type |  Warning alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| **critical | Yes | Type |  Critical alert |
| ***value | Yes | Integer |  Warning to be issued when the threshold is reached. from 1 to 100 |
| ***alert | Yes | Boolean |  If set true warning will be issued. |
| ports | No | Collection | Collection of ports that are to be monitored for the given condition |
| *email_notification | Yes | boolean |  If set true email will be sent. |
| *port | Yes | Integer |  Port number. |
| *protocol | Yes | String |  The protocol of the port ["TCP", "UDP", "TCP/UDP", "ICMP", "IPSEC"]|
| *alert_if | Yes | String |  Condition for the alert to be issued. |
| processes | No | Collection | Collection of processes that are to be monitored for the given condition |
| *email_notification | Yes | Boolean |  If set true email will be sent. |
| *process | Yes | Integer |  Process name. |
| *alert_if | Yes | String |  Condition for the alert to be issued. |


### Load Balancer

#### Example Load Balancer

```$xslt
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
```
#### Argument Reference

 Parameter | Required | Type | Description |
|---|---|---|---|
| name | Yes | String | The name of the load balancer. |
| description | No | String | Description for the load balancer |
| method | Yes | String | Balancing procedure ["ROUND_ROBIN", "LEAST_CONNECTIONS"] |
| datacenter | No | String |  Location of desired 1and1 datacenter ["DE", "GB", "US", "ES" ] |
| persistence | No | Boolean |  True/false defines whether persistence should be turned on/off |
| persistence_time | No | Integer | Persistance duration in seconds |
| health_check_test | No | String | ["TCP", "ICMP"]  |
| health_check_test_interval | No | String |   |
| health_check_test_path | No | String |   |
| health_check_test_parser | No | String |   |
| rules | Yes | Collection |  Collection of load balancing rules |
| *protocol | Yes | String |  The protocol for the rule ["TCP", "UDP", "TCP/UDP", "ICMP", "IPSEC"]|
| *port_balancer | Yes | String |   |
| *port_server | Yes | String |   |
| *source_ip | Yes | String |   |
