/*
 * Common
 */

variable "projectname" {
  description = "Project Name"
}

variable "instance" {
  description = "DNS-compatible Instance Name"
}

variable "environment" {
  description = "DNS-compatible Environment Name (dev, stag, prod)"
}

variable "region" {
  description = "Azure Region"
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

variable "location"  {
  description = "set Azure Location e.g. eastus or westeurope"
  type = "string"
}

/*
 * K8S
 */

variable "K8S_KUBE_CONFIG" {
  description = "Path to Kube Config File"
}

variable "K8S_HELM_HOME" {
  description = "Path to Helm Home Directory"
}

/*
 * AKS
 */

variable "AKS_SSH_ADMIN_KEY" {
  description = "Admin SSH Public Key for AKS Agent VMs"
}

variable "agent_count" {
  default = 1
}
