# Configure the Microsoft Azure Provider
provider "azurerm" { }

# Resource Group
resource "azurerm_resource_group" "application" {
  name     = "${var.projectname}-${var.environment}"
  location = "${var.location}"

  tags {
    project = "${var.projectname}"
    environment = "${var.environment}"
  }
}

# service principal for aks
resource "azurerm_azuread_application" "aks" {
  name = "${var.projectname}-${var.environment}-aks"
}

resource "azurerm_azuread_service_principal" "aks" {
  application_id = "${azurerm_azuread_application.aks.application_id}"
}

resource "random_string" "aks-principal-secret" {
  length  = 30
  special = true
}

resource "azurerm_azuread_service_principal_password" "aks" {
  service_principal_id = "${azurerm_azuread_service_principal.aks.id}"
  value                = "${random_string.aks-principal-secret.result}"
  end_date             = "2100-01-01T00:00:00Z"
}

//data "azurerm_subscription" "primary" {}

//data "azurerm_client_config" "cxconfig" {}

//resource "azurerm_role_definition" "cxrole" {
//  role_definition_id = "00000000-0000-0000-0000-000000000000"
//  name               = "cxrole"
//  scope              = "${data.azurerm_subscription.primary.id}"

//  permissions {
//    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
//    not_actions = []
//  }

//  assignable_scopes = [
//    "${data.azurerm_subscription.primary.id}",
//  ]
//}

//resource "azurerm_role_assignment" "aks-cxrole" {
//  name               = "00000000-0000-0000-0000-000000000000"
//  scope              = "${data.azurerm_subscription.primary.id}"
//  role_definition_id = "${azurerm_role_definition.cxrole.id}"
//  principal_id         = "${azurerm_azuread_service_principal.aks.id}"
//}

//resource "azurerm_role_assignment" "aks-network-contributor" {
//  scope                = "${azurerm_resource_group.application.id}"
//  role_definition_name = "Network Contributor"
//  principal_id         = "${azurerm_azuread_service_principal.aks.id}"
//}

# kubernetes cluster
resource "azurerm_kubernetes_cluster" "application" {
  name                = "${var.projectname}-${var.environment}-aks"
  location            = "${azurerm_resource_group.application.location}"
  resource_group_name = "${azurerm_resource_group.application.name}"
  //depends_on = [
    //"azurerm_role_assignment.aks-cxrole",
    //"azurerm_public_ip.ingress_ip"
  //]
  dns_prefix         = "${var.projectname}${var.environment}"
  kubernetes_version = "1.11.7"

  linux_profile {
    admin_username = "cxcloud"
    ssh_key {
      key_data = "${var.AKS_SSH_ADMIN_KEY}"
    }
  }
  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 50
  }
  service_principal {
    client_id     = "${azurerm_azuread_application.aks.application_id}"
    client_secret = "${azurerm_azuread_service_principal_password.aks.value}"
  }

  tags {
    project = "${var.projectname}"
    environment = "${var.environment}"
  }
}

//# kube config and helm init
//resource "local_file" "kube_config" {
//  # kube config
//  filename = "${var.K8S_KUBE_CONFIG}"
//  content  = "${azurerm_kubernetes_cluster.application.kube_config_raw}"

//  # helm init
//provisioner "local-exec" {
//    command = "helm init --client-only"
//      environment {
//      KUBECONFIG = "${var.K8S_KUBE_CONFIG}"
//      HELM_HOME  = "${var.K8S_HELM_HOME}"
//    }
//  }
//}

# Initialize Helm (and install Tiller)
provider "helm" {
  install_tiller = true

  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.application.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.application.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.application.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.application.kube_config.0.cluster_ca_certificate)}"
  }
}


# Create Static Public IP Address to be used by Nginx Ingress
resource "azurerm_public_ip" "nginx_ingress" {
  name                         = "nginx-ingress-pip"
  location                     = "${azurerm_kubernetes_cluster.application.location}"
  resource_group_name          = "${azurerm_kubernetes_cluster.application.node_resource_group}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.projectname}${var.environment}"
}

# ingress
resource "helm_release" "ingress" {
  name      = "ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  timeout   = 1800

  set {
    name  = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.nginx_ingress.ip_address}"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
}

# cert-manager
resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"
  timeout   = 1800
  version   = "v0.5.2"
  depends_on = [ "helm_release.ingress" ]

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
}

# letsencrypt
resource "helm_release" "letsencrypt" {
  name      = "letsencrypt"
  chart     = "${path.root}/charts/letsencrypt/"
  namespace = "kube-system"
  timeout   = 1800
  depends_on = [ "helm_release.cert-manager" ]
}