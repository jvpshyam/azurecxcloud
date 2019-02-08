# Terraform for Azure File Volume for AKS.
# Generates a Random ID to be used for the SA name.
resource "random_id" "application_volume_sa_random" {
  byte_length = 6
  keepers {
    sa_account_ref = 1
  }
}

# Storage Account in which the Storage Container will be created in.
resource "azurerm_storage_account" "application_volume_sa" {
  name                     = "${random_id.application_volume_sa_random.hex}"
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group_name}"
  account_replication_type = "${var.application_volume_sa_replication_type}"
  account_tier             = "${var.application_volume_sa_tier}"
  enable_file_encryption   = "true"
  enable_https_traffic_only = "true"
  account_encryption_source = "Microsoft.Storage"

  lifecycle {
    prevent_destroy = false
  }

  #  tags = "${(var.resource_tags, map("Name", "${var.projectname}-${var.location}-aks-volume"))}"

}

# Creation of the storage Container
resource "azurerm_storage_container" "application_volume" {
  name = "${var.projectname}-tf-aks"
  resource_group_name = "${var.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.application_volume_sa.name}"
  container_access_type = "private"
  lifecycle {
    prevent_destroy = false
  }
}