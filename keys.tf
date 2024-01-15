resource "tls_private_key" "this" {
  count = var.ssh_key_path != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "create_ssh_priv_key_file" {
  count = var.ssh_key_path == "" ? 1 : 0
  content = "${local.priv_key}"
  filename = "key.pem"
  file_permission  = "0600"
}