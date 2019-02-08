output "storage-account-name" {
  value = "${azurerm_storage_account.application_volume_sa.name}"
}

output "storage_account_id" {
  value = "${azurerm_storage_account.application_volume_sa.id}"
}

output "container-name" {
  value = "${azurerm_storage_container.application_volume.name}"
}