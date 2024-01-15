locals {
  preffix   = "${var.labels.service}"
  domain = "${var.k8s_domain}"
  #get private key
  priv_key = var.ssh_key_path == "" ? tls_private_key.this[0].private_key_pem : file(pathexpand("${var.ssh_key_path}/${var.ssh_key_name}"))
  pub_key = var.ssh_key_path == "" ? tls_private_key.this[0].public_key_openssh : file(pathexpand("${var.ssh_key_path}/${var.ssh_key_name}.pub"))
}