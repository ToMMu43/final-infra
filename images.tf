# Добавление готовых образов ВМ

resource "yandex_compute_image" "nat-instance-ubuntu" {
  source_family = "nat-instance-ubuntu"
}

data "yandex_compute_image" "debian" {
  family = "${var.os_family}-${var.os_version}"
}

