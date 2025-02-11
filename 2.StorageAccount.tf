resource "azurerm_resource_group" "app-grp" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage-account" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.app-grp.name
  location                 = azurerm_resource_group.app-grp.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "data" {
    name = "data"
    storage_account_name = azurerm_storage_account.storage-account.name 
    container_access_type = "private"
  
}

resource "azurerm_storage_blob" "example" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = azurerm_storage_account.storage-account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "some-local-file.zip"
#  Dependencies between resources
  depends_on = [ azurerm_resource_group.app-grp ]
}
