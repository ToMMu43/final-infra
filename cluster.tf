

# Compute instance group for masters

resource "yandex_compute_instance_group" "masters" {
  name               = "${local.preffix}-masters"
  service_account_id = "${yandex_iam_service_account.this.id}"
  folder_id          = "${var.folder_id}"

  instance_template {
    name = "${var.masters_name}-{instance.index}"
    platform_id = "standard-v1"
    resources {
      cores  = "${var.masters_resources.cpu}"
      memory = "${var.masters_resources.memory}"
      core_fraction = "${var.masters_resources.core_fraction}"
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${data.yandex_compute_image.debian.id}"
        size     = "${var.masters_resources.disk}"
        type     = "${var.masters_resources.disk_type}"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.this.id}"
      subnet_ids = "${yandex_vpc_network.this.subnet_ids}"
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-nat-sg.id}",
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}",
        "${yandex_vpc_security_group.k8s-master-whitelist.id}"
      ]  

    }

    metadata = {
      ssh-keys = "debian:${local.pub_key}"
    
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = "${var.masters_count}"
    }
  }

  allocation_policy {
    zones = var.az
  }

  deploy_policy {
    max_unavailable = "${var.masters_count}"
    max_creating    = "${var.masters_count}"
    max_expansion   = "${var.masters_count}"
    max_deleting    = "${var.masters_count}"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.this, 
    yandex_iam_service_account.this,
    yandex_vpc_network.this,
    yandex_vpc_route_table.this, 
    yandex_vpc_subnet.private, 
    yandex_vpc_subnet.public,
  ]

}

# Compute instance group for workers

resource "yandex_compute_instance_group" "workers" {
  name               = "${local.preffix}-workers"
  service_account_id = "${yandex_iam_service_account.this.id}"
  folder_id          = "${var.folder_id}"

  instance_template {
    name = "${var.workers_name}-{instance.index}"
    platform_id = "standard-v1"
    resources {
      cores  = "${var.workers_resources.cpu}"
      memory = "${var.workers_resources.memory}"
      core_fraction = "${var.workers_resources.core_fraction}"
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${data.yandex_compute_image.debian.id}"
        size     = "${var.workers_resources.disk}"
        type     = "${var.workers_resources.disk_type}"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.this.id}"
      subnet_ids = "${yandex_vpc_network.this.subnet_ids}"
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-nat-sg.id}",
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}"
      ]
    }

    metadata = {
      ssh-keys = "debian:${local.pub_key}"
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = "${var.workers_count}"
    }
  }

  allocation_policy {
    zones = var.az
  }

  deploy_policy {
    max_unavailable = "${var.workers_count}"
    max_creating    = "${var.workers_count}"
    max_expansion   = "${var.workers_count}"
    max_deleting    = "${var.workers_count}"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.this, 
    yandex_iam_service_account.this,
    yandex_vpc_network.this,
    yandex_vpc_route_table.this, 
    yandex_vpc_subnet.private, 
    yandex_vpc_subnet.public,
  ]
}

# Compute instance group for ingresses

resource "yandex_compute_instance_group" "ingresses" {
  name               = "${local.preffix}-ingresses"
  service_account_id = "${yandex_iam_service_account.this.id}"
  folder_id          = "${var.folder_id}"

  instance_template {
    name = "${var.ingresses_name}-{instance.index}"
    platform_id = "standard-v1"
    resources {
      cores  = "${var.ingresses_resources.cpu}"
      memory = "${var.ingresses_resources.memory}"
      core_fraction = "${var.ingresses_resources.core_fraction}"
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${data.yandex_compute_image.debian.id}"
        size     = "${var.ingresses_resources.disk}"
        type     = "${var.ingresses_resources.disk_type}"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.this.id}"
      subnet_ids = "${yandex_vpc_network.this.subnet_ids}"
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-nat-sg.id}",
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}",
        "${yandex_vpc_security_group.k8s-ingress-loadbalance.id}"
      ]
    }

    metadata = {
      ssh-keys = "debian:${local.pub_key}"
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = "${var.ingresses_count}"
    }
  }

  allocation_policy {
    zones = var.az
  }

  deploy_policy {
    max_unavailable = "${var.ingresses_count}"
    max_creating    = "${var.ingresses_count}"
    max_expansion   = "${var.ingresses_count}"
    max_deleting    = "${var.ingresses_count}"
  }

  load_balancer {
    target_group_name = "ingresses-target-group"
  }
  
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.this, 
    yandex_iam_service_account.this,
    yandex_vpc_network.this,
    yandex_vpc_route_table.this, 
    yandex_vpc_subnet.private, 
    yandex_vpc_subnet.public,
  ]
}

  # health_check {
  #   interval            = "2"
  #   timeout             = "1"
  #   healthy_threshold   = "5"
  #   unhealthy_threshold = "5"
  #   http_options {
  #     port = "80"
  #     path = "/"
  #   }
  # }

  # application_load_balancer {
  #   target_group_name = "${local.preffix}-alb-tg"
  # }


