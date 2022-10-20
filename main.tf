# Inicializando provider
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.23.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Configurando maquina virtual - JENKIS
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-18-04-x64"
  name     = "jenkis"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

#  Configurando chave ssh para aceso a maquina virtual
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key
}

# Configurando cluster kubernetes
resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

#Adicionando variavéis
variable "do_token" {
  default = ""
}

variable "region" {
  default = ""
}

variable "ssh_key" {
  default = ""
}


output "jenkis_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
  content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}