resource "yandex_compute_instance" "bastion" {

  name        = "bastion"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  labels = var.labels

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.debian.id}"
      size     = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "debian:${local.pub_key}"
  }
   
  scheduling_policy {
    preemptible = true
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.this,
    yandex_iam_service_account.this,
    yandex_vpc_subnet.public,
  ]
}

resource "null_resource" "prepare_bastion" {
  count = "${var.action == "create_cluster" ? 1 : 0}"

  depends_on = [
    yandex_compute_instance.bastion
  ]
  
  connection {
    host        = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    type        = "ssh"
    user        = "${var.ansible_username}"
    private_key = "${local.priv_key}"
    agent       = false
  } 

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo apt update -y && sudo apt install git python3-venv pip mc -y",
      "export LC_ALL=C.UTF-8",
      "cd /home/${var.ansible_username}",
      "git clone --branch ${var.kubespray_version} ${var.kubespray_url}",
      "cd kubespray && pip install -U -r requirements.txt",
      "mkdir -p /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc",
      "sudo cp /home/\"${var.ansible_username}\"/.local/bin/ansible* /usr/bin/",
      "echo Check ansible version && ansible --version",
      "wget -qO- https://get.docker.com/ | sh",
      "sudo docker pull derailed/k9s:latest",
      "cd && mkdir helm && cd helm && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",
      "echo Ansible, Python, Docker, Helm and k9s-in-docker are added. Done"
    ]
  }
}
