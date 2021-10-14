provider "azurerm" {
  features {}
  storage_use_azuread = true
}


data "http" "my_ip" {
  url = "https://ifconfig.me"
} 

data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  special = false
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}


module "storage_account" {
  source = "github.com/Azure-Terraform/terraform-azurerm-storage-account.git"
  for_each            = var.name
  name                = each.value
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  replication_type    = var.replication_type
  enable_large_file_share = true
  
  access_list = {
    "my_ip" = data.http.my_ip.body
  }

  
  

  blob_cors = {
    test = {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "DELETE"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 5
    }
  }
}