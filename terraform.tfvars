# Generating an ssh-key if these lines are commented
#ssh_key_path = "~/.ssh"
#ssh_key_name = "id_rsa"

#Configure OS for VM

os_family = "debian"
os_version = "11"

#Configure Kubespray

k8s_version = "v1.25.6"
k8s_domain = "s056635.local"
kubespray_version = "v2.21.0"
kubespray_url = "https://github.com/kubernetes-sigs/kubespray"

#Configure resources for k8s nodes

masters_count = "3"
ingresses_count = "2"
workers_count = "1"

masters_name = "master"
ingresses_name = "ingress"
workers_name = "node"

masters_resources = ({
  disk = 10
  disk_type = "network-ssd"
  cpu = 2
  memory = 2
  core_fraction = 20
})

workers_resources = ({
  disk = 10
  disk_type = "network-hdd"
  cpu = 2
  memory = 2
  core_fraction = 20
})

ingresses_resources = ({
  disk = 10
  disk_type = "network-hdd"
  cpu = 2
  memory = 2
  core_fraction = 20
})

labels = {
  "service" = "k8s"
  "student_number" = "s056635"
}

cidr_blocks = [
  ["10.20.0.0/24"],
  ["10.30.0.0/24"]
]

nat_zone = "ru-central1-a"
nat_cidr_blocks =  ["10.10.0.0/24"]

nlb_http_healthcheck = ({
  name = "http"
  port = 32080
  path = "/"
})

nlb_https_healthcheck = ({
  name = "http"
  port = 32443
  path = "/"
})

http_listener_port = 80
https_listener_port = 443