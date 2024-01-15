# Network creating

resource "yandex_vpc_network" "this" {
  name = "private-network"
}

resource "yandex_vpc_subnet" "private" {
  for_each = toset(var.az)

  name           = "${local.preffix}-${each.value}"
  zone           = each.value
  network_id     = var.vpc_id != "" ? var.vpc_id : "${yandex_vpc_network.this.id}"
  v4_cidr_blocks = var.cidr_blocks[index(var.az, each.value)]
  labels         = var.labels
  route_table_id = yandex_vpc_route_table.this.id
}

# Public - for bastion VM for NAT

resource "yandex_vpc_subnet" "public" {
  name           = "nat-subnet"
  zone           = "${var.nat_zone}"
  network_id     = var.vpc_id != "" ? var.vpc_id : "${yandex_vpc_network.this.id}"
  v4_cidr_blocks = var.nat_cidr_blocks
  labels         = var.labels
}