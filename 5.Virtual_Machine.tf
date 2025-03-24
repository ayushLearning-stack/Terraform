provider "azurerm" {
  features {}
}

locals {
  resource_group = "app-grp"
  location = "West Europe"
}

data "azurerm_subnet" "app-grp-subnet-A" {
    name = "app-grp-subnet-A"
    virtual_network_name = "app-grp-virtual_network"
    resource_group_name = local.resource_group
  
}

resource "azurerm_resource_group" "app-grp" {
  name     = "app-grp-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "app-grp-virtual_network" {
  name                = "app-grp-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app-grp.location
  resource_group_name = azurerm_resource_group.app-grp.name
}

resource "azurerm_subnet" "app-grp-subnet-A" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.app-grp.name
  virtual_network_name = azurerm_virtual_network.app-grp-virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "app-grp-network-interface" {
  name                = "app-grp-nic"
  location            = azurerm_resource_group.app-grp.location
  resource_group_name = azurerm_resource_group.app-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.app-grp-subnet-A.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [ azurerm_public_ip.app_public_ip ]
}

resource "azurerm_windows_virtual_machine" "app-grp-vm" {
  name                = "app-grp-machine"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = azurerm_resource_group.app-grp.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.app-grp.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "app_public_ip" {
    name = "app_public_ip"
    resource_group_name = azurerm_resource_group.app-grp.name
    location = azurerm_resource_group.app-grp.location
    allocation_method = "Static"

  
}


resource "azurerm_managed_disk" "app-grp-disk" {
    name = "app-grp-disk"
    location = local.location
    resource_group_name = local.resource_group
    storage_account_type = "Stnadard_LRS"
    create_option = "Empty"
    disk_size_gb = 16
  
}

resource "azurerm_virtual_machine_data_disk_attachment" "app-grp-disk-attach" {
  managed_disk_id = azurerm_managed_disk.app-grp-disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.app-grp-vm.id
  lun = 0
  caching = "ReadWrite"
  depends_on = [ azurerm_managed_disk.app-grp-disk,
  azurerm_windows_virtual_machine.app-grp-vm ]

}