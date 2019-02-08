variable "projectname"  {
  description = "set the name of the project"
  type = "string"
}

variable "location"  {
  description = "set Azure Location e.g. eastus or westeurope"
  type = "string"
}

variable "application_volume_sa_replication_type"  {
  description = "set replication type for the Storage Account"
  type = "string"
  default = "LRS"
}

variable "application_volume_sa_tier"  {
  description = "Set the Storage Tier e.g. to Standard or Premium"
  type = "string"
}

variable "resource_group_name"  {
  description = "Set the Resource Group Name of the k8s Cluster"
  type = "string"
}
