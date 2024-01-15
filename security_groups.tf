# Создание группы безопасности

resource "yandex_vpc_security_group" "k8s-nat-sg" {
  name       = "k8s-nat-sg"
  description = "Правила разрешают использовать для исходящего трафика nat-instance в публичной сети"
  network_id = "${yandex_vpc_network.this.id}"

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

    ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ICMP"
    description    = "ext-icmp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "k8s-main-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера. Применяется ко всем узлам кластера"
  network_id  = "${yandex_vpc_network.this.id}"
  
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера и сервисов."
    v4_cidr_blocks = ["10.233.64.0/18", "10.233.0.0/18"]

    # v4_cidr_blocks = "${concat("${var.cidr_blocks[0]}","${var.cidr_blocks[1]}")}"
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "ICMP"
    description    = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks = ["172.16.0.0/12", "10.0.0.0/8", "192.168.0.0/16"]
  }
}

# resource "yandex_vpc_security_group" "k8s-public-services" {
#   name        = "k8s-public-services"
#   description = "Правила группы разрешают подключение к сервисам из интернета. Применяется только для воркер- и ингресс-узлов"
#   network_id  = "${yandex_vpc_network.this.id}"

#   ingress {
#     protocol       = "TCP"
#     description    = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 30000
#     to_port        = 32767
#   }
# }

resource "yandex_vpc_security_group" "k8s-nodes-ssh-access" {
  name        = "k8s-nodes-ssh-access"
  description = "Правила группы разрешают подключение к узлам кластера по SSH. Применяется ко всем узлам кластера"
  network_id  = "${yandex_vpc_network.this.id}"

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к узлам по SSH с указанных IP-адресов."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-whitelist"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета. Применяется только к мастер-узлам"
  network_id  = "${yandex_vpc_network.this.id}"

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}

resource "yandex_vpc_security_group" "k8s-ingress-loadbalance" {
  name        = "k8s-ingress-loadbalance"
  description = "Правила группы разрешают доступ по http/https из интернета. Применяется к ingress-узлам"
  network_id  = "${yandex_vpc_network.this.id}"

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение через порт 80 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение через порт 443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}