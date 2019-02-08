# Configure the Microsoft Azure Provider
provider "azurerm" { }

# Resource Group
resource "azurerm_resource_group" "application" {
  name     = "${var.projectname}-${var.instance}-${var.environment}"
  location = "${var.region}"

  tags {
    project = "${var.projectname}"
    instance = "${var.instance}"
    environment = "${var.environment}"
  }
}

# Azure File
# ToDo Create Condition if to be created or not.
module "azure-file" {
  source  = "./terraform-storage"
  projectname = "${var.projectname}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.application.name}"
  application_volume_sa_replication_type = "${var.application_volume_sa_replication_type}"
  application_volume_sa_tier = "${var.application_volume_sa_tier}"
}