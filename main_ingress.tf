# ingress ip
resource "azurerm_public_ip" "ingress_ip" {
  name                = "${var.projectname}${var.instance}${var.environment}iip"
  location            = "${azurerm_resource_group.application.location}"
  resource_group_name = "${azurerm_resource_group.application.name}"

  public_ip_address_allocation = "static"
  domain_name_label            = "${var.projectname}${var.instance}${var.environment}"

  tags {
    project = "${var.projectname}"
    instance = "${var.instance}"
    environment = "${var.environment}"
  }
}

# helm provider
provider "helm" {
  debug = true
  home  = "${var.K8S_HELM_HOME}"
  kubernetes {
    config_path = "${local_file.kube_config.filename}"
  }
}

# ingress
resource "helm_release" "ingress" {
  name      = "ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  timeout   = 1800

  set {
    name  = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.ingress_ip.ip_address}"
  }
  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group\""
    value = "${azurerm_resource_group.application.name}"
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