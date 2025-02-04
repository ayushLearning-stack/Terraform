terraform {  
  required_version = "> 0.12.0"  
  
  required_providers {  
    azurerm = {  
      source  = "hashicorp/azurerm"  
      version = "~> 4.17.0"  # Ensure this matches your lock file  
    }  
  }  
}  
  
provider "azurerm" {  
  features {}  
  
  # Authentication details  
  subscription_id = "2f51a067-6f3c-48be-9818-3c02a1508247"   
}  
  
resource "azurerm_resource_group" "app_grp" {  
  name     = "app-grp"  
  location = "North Europe"  
}  
