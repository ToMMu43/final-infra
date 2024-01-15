resource "null_resource" "kubespray_replacement_trigger" {
  depends_on = [ 
    yandex_compute_instance_group.masters,
    yandex_compute_instance_group.ingresses,
    yandex_compute_instance_group.workers
  ]
  
  triggers = {
    workers_count = "${var.workers_count}",
    ingresses_count = "${var.ingresses_count}",
    domain = "${var.k8s_domain}",
    version = "${var.k8s_version}"
  }
}

resource "local_file" "kubespray_inventory" {
  filename = "kubespray_config/inventory.ini"
  file_permission  = "0644"
  depends_on = [ 
    yandex_compute_instance_group.masters,
    yandex_compute_instance_group.ingresses,
    yandex_compute_instance_group.workers
  ]

  content = templatefile("templates/kubespray_inventory.tmpl", {
    master_hostnames = "${yandex_compute_instance_group.masters.instances.*.name}",
    worker_hostnames = "${yandex_compute_instance_group.workers.instances.*.name}",
    ingress_hostnames = "${yandex_compute_instance_group.ingresses.instances.*.name}",
    master_ansible_hosts = "${yandex_compute_instance_group.masters.instances.*.network_interface.0.ip_address}",
    worker_ansible_hosts = "${yandex_compute_instance_group.workers.instances.*.network_interface.0.ip_address}",
    ingress_ansible_hosts = "${yandex_compute_instance_group.ingresses.instances.*.network_interface.0.ip_address}",
    domain = "${var.k8s_domain}"
  })

  lifecycle {
    replace_triggered_by = [ 
      null_resource.kubespray_replacement_trigger,
    ]
  }
}

resource "local_file" "kubespray_config" {
  filename = "kubespray_config/group_vars/k8s_cluster/k8s-cluster.yml"
  file_permission  = "0644"
  
  content = templatefile("templates/k8s-cluster.tmpl", {
    domain = "${var.k8s_domain}",
    version = "${var.k8s_version}"
  })

  lifecycle {
    replace_triggered_by = [ 
      null_resource.kubespray_replacement_trigger,
    ]
  }
}

resource "null_resource" "configure_kubespray" {
  depends_on = [ 
    local_file.create_ssh_priv_key_file,
    local_file.kubespray_inventory,
    local_file.kubespray_config,
    null_resource.prepare_bastion
  ]

  connection {
    host        = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    type        = "ssh"
    user        = "${var.ansible_username}"
    private_key = "${local.priv_key}"
    agent       = false
  }  

  provisioner "file" {
    source      = "./kubespray_config/"
    destination = "/home/${var.ansible_username}/kubespray/inventory/slurm-yc"
  }
  
  provisioner "file" {
    source      = "./key.pem"
    destination = "/home/${var.ansible_username}/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "./manifests/"
    destination = "/home/${var.ansible_username}/manifests"
    on_failure = continue
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "create_cluster" {
  count = "${var.action == "create_cluster" ? 1 : 0}"

  depends_on = [ 
    yandex_compute_instance.bastion, 
    local_file.create_ssh_priv_key_file,
    local_file.kubespray_inventory,
    local_file.kubespray_config,
    null_resource.prepare_bastion,
    null_resource.configure_kubespray
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
      "echo 'Run ansible playbook'",
      "chmod 0600 /home/\"${var.ansible_username}\"/.ssh/id_rsa",
      "cd /home/\"${var.ansible_username}\"/kubespray",
      "ansible-playbook -u \"${var.ansible_username}\" -i inventory/slurm-yc/inventory.ini cluster.yml -b --diff",
      "echo Cluster k8s deployed successfully",
      "echo Add kubectl to Bastion host",
      "sudo cp /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/artifacts/kubectl /usr/local/bin/kubectl",
      "echo Add kubeconfig for user",
      "mkdir -p /home/\"${var.ansible_username}\"/.kube",
      "cp /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/artifacts/admin.conf /home/\"${var.ansible_username}\"/.kube/config",
      "chown $(id -u):$(id -g) /home/\"${var.ansible_username}\"/.kube/config",
      "export KUBECONFIG=/home/\"${var.ansible_username}\"/.kube/config",
      "echo 'export KUBECONFIG=/home/\"${var.ansible_username}\"/.kube/config' >> /home/\"${var.ansible_username}\"/.bashrc",
      "echo Check k8s installation by using kubectl",
      "kubectl get nodes -o wide",
      "echo Save ip-addresses of nodes for next variable steps",
      "cp /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/inventory.ini /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/hosts.ini"
    ]
  }
}

resource "null_resource" "add_workers" {
  count = "${var.action == "add_workers" ? 1 : 0}"

  depends_on = [ 
    yandex_compute_instance.bastion, 
    local_file.kubespray_inventory,
    local_file.kubespray_config,
    null_resource.prepare_bastion,
    null_resource.configure_kubespray,
    yandex_compute_instance_group.workers,
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
      "echo 'Update k8s - cluster - scale nodes'",
      "export PATH=\"/home/\"${var.ansible_username}\"/.local/bin/:$PATH\"",
      "export LC_ALL=C.UTF-8",
      "cd /home/\"${var.ansible_username}\"/kubespray",
      "ansible-playbook -u \"${var.ansible_username}\" -i inventory/slurm-yc/inventory.ini scale.yml -b --diff",
      "kubectl get nodes -o wide",
      "cp /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/inventory.ini /home/\"${var.ansible_username}\"/kubespray/inventory/slurm-yc/hosts.ini",
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
  
}

resource "null_resource" "remove_workers" {
  count = "${var.action == "remove_workers" ? 1 : 0}"

  depends_on = [ 
    yandex_compute_instance.bastion, 
    local_file.kubespray_inventory,
    local_file.kubespray_config,
    null_resource.prepare_bastion,
    null_resource.configure_kubespray,
    yandex_compute_instance_group.workers
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
      "echo 'Update k8s - cluster - remove NotReady workers nodes'",
      "export LC_ALL=C.UTF-8",
      "cd /home/\"${var.ansible_username}\"/kubespray",
      "export DELETE_NODE=$(kubectl get nodes | grep NotReady | awk -F' ' '{print $1}')",
      # "ansible-playbook -u \"${var.ansible_username}\" -i inventory/slurm-yc/hosts.ini remove-node.yml -e {\"node\":\"$DELETE_NODE\", \"reset_nodes\":\"false\", \"allow_ungraceful_removal\": \"true\", \"skip_confirmation\": \"yes\"} -b --diff",
      "ansible-playbook -u \"${var.ansible_username}\" -i inventory/slurm-yc/hosts.ini remove-node.yml -e \"node=$DELETE_NODE reset_nodes=false allow_ungraceful_removal=true skip_confirmation=yes\" -b --diff",
      "kubectl get nodes -o wide",
    ]
  }
  
  triggers = {
    always_run = "${timestamp()}"
  }
}