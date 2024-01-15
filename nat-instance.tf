
# Создание ВМ NAT

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.nat-instance-ubuntu.id
    }
  }

  network_interface {
    subnet_id          = "${yandex_vpc_subnet.public.id}"
    security_group_ids = ["${yandex_vpc_security_group.k8s-nat-sg.id}"]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${local.pub_key}"
  }
}


# Создание таблицы маршрутизации и статического маршрута

resource "yandex_vpc_route_table" "this" {
  name       = "${local.preffix}-nat-instance-route"
  network_id = yandex_vpc_network.this.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}