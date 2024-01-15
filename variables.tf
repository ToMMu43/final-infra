variable "folder_id" {
  type = string
  description = "folder id for current project"
}

# Preferred OS for create VM for nodes

variable "os_family" {
  type = string
  description = "OS family for create VM"
}

variable "os_version" {
  type = string
  description = "OS version for create VM"
}

# Variables for Kubespray

variable "k8s_version" {
  type = string
  description = "K8S version"
}

variable "kubespray_version" {
  type = string
  description = "kubespray version"
}

variable "k8s_domain" {
  type = string
  description = "Domain name for k8s cluster"
}

variable "kubespray_url" {
  type = string
  description = "Kubespray URL for download to bastion"
}

variable "action" {
  type = string
  description = "Which action have to be done on the cluster (create_cluster, add_workers, remove_workers or upgrade)"
  default     = "create_cluster"
}

# Count VM for nodes

variable "masters_count" {
  type = number
  description = "Number of VM for k8s-master-nodes"
}

variable "ingresses_count" {
  type = number
  description = "Number of VM for k8s-ingress-nodes"
}

variable "workers_count" {
  type = number
  description = "Number of VM for k8s-worker-nodes"
}

# Name for nodes

variable "masters_name" {
  type = string
  description = "name of VM for k8s-master-nodes"
}

variable "ingresses_name" {
  type = string
  description = "name of VM for k8s-ingress-nodes"
}
variable "workers_name" {
  type = string
  description = "name of VM for k8s-worker-nodes"
}

# Resources for nodes

variable "masters_resources" {
  type = object({
    disk = number
    disk_type = string
    memory = number
    cpu = number
    core_fraction = number
  })
  description = "set of resources for k8s-master-nodes"
}

variable "workers_resources" {
  type = object({
    disk = number
    disk_type = string
    memory = number
    cpu = number
    core_fraction = number
  })
  description = "set of resources for k8s-worker-nodes"
}

variable "ingresses_resources" {
  type = object({
    disk = number
    disk_type = string
    memory = number
    cpu = number
    core_fraction = number
  })
  description = "set of resources for k8s-ingress-nodes"
}

variable "labels" {
  type = map(string)
  description = "Lables to add to resources"
}

variable "cidr_blocks" {
  type = list(list(string))
  description = "List of lists of IPv4 cidr blocks for subnets"
}

variable "vpc_id" {
  type = string
  default = ""
  description = "VPC ID"
}

variable "http_listener_port" { 
  type = number
  description = "External http port for network load balancer"
}

variable "https_listener_port" { 
  type = number
  description = "External https port for network load balancer"
}

variable "nlb_http_healthcheck" {
  type = object ({
    name = string
    port = number
    path = string
  })
}

variable "nlb_https_healthcheck" {
  type = object ({
    name = string
    port = number
    path = string
  })
}

variable "ansible_username" {
  type = string
  description = "username for running ansible playbook"
  default = "debian"
} 

variable "ssh_key_path" {
  type = string
  description = "path to ssh key"
  default = ""
}

variable "ssh_key_name" {
  type = string
  description = "name for ssh key"
  default = ""
}

variable "az" {
  type = list(string)
  default = [
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "nat_cidr_blocks" {
  type = list(string)
  description = "List of lists of IPv4 cidr blocks for nat subnet"
}

variable "nat_zone" {
  type = string
  default = "ru-central1-a"
}  

variable "vm_user_nat" {
  type = string
  default = "user"
}