# Service account
resource "yandex_iam_service_account" "this" {
  name        = "${local.preffix}-sa"
  description = "sa for control cluster"
#  depends_on  = [yandex_vpc_subnet.private]
}

# Binding roles for service account
resource "yandex_resourcemanager_folder_iam_binding" "this" {
  folder_id   = "${var.folder_id}"
  role        = "editor"
  members     = [
    "serviceAccount:${yandex_iam_service_account.this.id}",
  ]
  depends_on = [yandex_iam_service_account.this]
}
