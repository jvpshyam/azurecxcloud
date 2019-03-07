
# Configure the Microsoft Storage account as per following details and update access_key to store terraform state
terraform {
  backend "azurerm" {
    storage_account_name = "cxcloudtfstatestorage"
    container_name       = "cxcloudtfstate"
    key                  = "terraform.tfstate"
    access_key           = "/tcZGD0AIBc3+y9uyXF8dGpHjkexLn+xXaUXtNEf4HNsdk9OP/ocbk2kyBbBoQmyunLFGEQa+2VJJPkQpFHnFA=="
  }
}