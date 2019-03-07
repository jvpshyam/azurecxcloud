/*
 * Common
 */

variable "projectname" {
  description = "Project Name"
  default = "cxcloud"
}

variable "environment" {
  description = "DNS-compatible Environment Name (dev, stag, prod)"
  default = "dev"
}

variable "application_volume_sa_replication_type"  {
  description = "set replication type for the Storage Account"
  type = "string"
  default = "LRS"
}

variable "application_volume_sa_tier"  {
  description = "Set the Storage Tier e.g. to Standard or Premium"
  type = "string"
  default = "Standard"
}

variable "location"  {
  description = "set Azure Location e.g. eastus or westeurope"
  type = "string"
  default = "EAST US"
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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU8o2ZnmPx3s5cgpEH0rOYIP9pHi0BtG5x1YELhQ+r42/wGuYKSfgqyj6mbueCqTYwb04cKER4ZirAr8Eh01S7Jb97rh0qj/gs9kq641woOCUlHaNES3isX4tmRyuhYYV9ZwCErKzWOaVrYnaKBcT3rXc7uYGOJJxLi7GHIvVaB9zSL1sO2p4RKPHnWemLJBjhl41Zn6lwyhxo7WVEf9oFH4ufWd1gZ2FzrzCxeE6Ook437g+WAuAuJaoWk8Rti5xXX1IOFpAkE2hmvfQpZEJzew/m2eFJJP7/kksn11SNTOPP+wF334IJW6MAXHIgQPzoH7U7c8rghT8/Vxz69Htb cxcloud@cxcloudlinux"
}

variable "agent_count" {
  default = 1
}
