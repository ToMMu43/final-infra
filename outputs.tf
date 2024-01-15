# data "yandex_compute_instance_group" "masters" {
#   instance_group_id = yandex_compute_instance_group.masters.id
# }

# data "yandex_compute_instance_group" "workers" {
#   instance_group_id = yandex_compute_instance_group.workers.id
# }


# data "yandex_compute_instance_group" "ingresses" {
#   instance_group_id = yandex_compute_instance_group.ingresses.id
# }

# data "yandex_compute_instance" "masters" {
#  instance_id = data.yandex_compute_instance_group.masters.id
# }

# data "yandex_compute_instance" "workers" {
#  instance_id = data.yandex_compute_instance_group.workers.id
# }

# data "yandex_compute_instance" "ingresses" {
#  instance_id = data.yandex_compute_instance_group.ingresses.id
# }

# Output values

output "bastion_external_ip" {
  description = "Public IP address for bastion"
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "nat_external_ip" {
  description = "Public IP address for nat-instance"
  value = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
}

output "lb_ingress_ip_address" {
  description = "Public IP address for loadbalance-interface"
  value = [for ex_ip in yandex_lb_network_load_balancer.this.listener: ex_ip.external_address_spec].0
}

output "instance_group_masters_private_ips" {
  description = "Private IP addresses for k8s-master-nodes"
  value = yandex_compute_instance_group.masters.instances.*.network_interface.0.ip_address
}

output "instance_group_masters_count" {
  description = "Count of VM for k8s-master-nodes"
  value = length(yandex_compute_instance_group.masters.instances)
}

output "instance_group_workers_private_ips" {
  description = "Private IP addresses for k8s-worker-nodes"
  value = yandex_compute_instance_group.workers.instances.*.network_interface.0.ip_address
}

output "instance_group_workers_count" {
  description = "Count of VM for k8s-worker-nodes"
  value = length(yandex_compute_instance_group.workers.instances)
}

output "instance_group_ingresses_private_ips" {
  description = "Private IP addresses for k8s-ingress-nodes"
  value = yandex_compute_instance_group.ingresses.instances.*.network_interface.0.ip_address
}

output "instance_group_ingresses_count" {
  description = "Count of VM for k8s-ingress-nodes"
  value = length(yandex_compute_instance_group.ingresses.instances)
}

output "private_key" {
  value     = var.ssh_key_path == "" ? tls_private_key.this[0].private_key_pem : ""
  sensitive = true
}



# output "master_ip_addresses" {
#   value = {
#     for instance_key, instance_value in data.yandex_compute_instance.masters :
#     instance_value.name => {
#       "private_ip" = instance_value.network_interface.0.ip_address
#       "public_ip"  = instance_value.network_interface.0.nat_ip_address
#     }
#   }
# }

# output "worker_ip_addresses" {
#   value = {
#     for instance_key, instance_value in data.yandex_compute_instance.workers :
#     instance_value.name => {
#       "private_ip" = instance_value.network_interface.0.ip_address
#       "public_ip"  = instance_value.network_interface.0.nat_ip_address
#     }
#   }
# }

# output "ingress_ip_addresses" {
#   value = {
#     for instance_key, instance_value in data.yandex_compute_instance.ingresses :
#     instance_value.name => {
#       "private_ip" = instance_value.network_interface.0.network_ip
#       "public_ip"  = instance_value.network_interface.0.nat_ip_address
#     }
#   }
# }