resource "yandex_lb_network_load_balancer" "this" {

  name = "${local.preffix}-lb-ingresses"

  depends_on = [
    yandex_compute_instance_group.ingresses
  ]

  listener {
    name = "http-listener"
    port = 80
    target_port = "${var.http_listener_port}"
    external_address_spec {
      ip_version = "ipv4"
    }  
  }

    listener {
    name = "https-listener"
    port = 443
    target_port = "${var.https_listener_port}"
    external_address_spec {
      ip_version = "ipv4"
    }  
  }

  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.ingresses.load_balancer.0.target_group_id}"
  
    healthcheck {
      name = "${var.nlb_http_healthcheck.name}"
      interval            = 20
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      http_options {
        port = "${var.nlb_http_healthcheck.port}"
        path = "${var.nlb_http_healthcheck.path}"
      }
    }
  }

}
