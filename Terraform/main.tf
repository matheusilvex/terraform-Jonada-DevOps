terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.token
}

# Create a web server
resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins-VM"
  region = var.region
  size   = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.Terraform.id]
}

data "digitalocean_ssh_key" "Terraform" {
  name = var.do_ssh_key
}

#Criação Kluster Kubernetes
resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.25.4-do.0"

  node_pool {
    name       = "default-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = "nyc1"
}

variable "token" {
  default = ""
}

variable "do_ssh_key" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "kubinf" {
    content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kubeconfig.yaml"  
}