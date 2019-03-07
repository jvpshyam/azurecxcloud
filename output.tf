/*
 * Kubernetes
 */
output "K8S_INGRESS_FQDN" {
  value = "${azurerm_public_ip.nginx_ingress.fqdn}"
  description = "Kubernetes Ingress FQDN"
}