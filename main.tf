// Define the Azure Terraform provider and minimum version required.
// During the inital Terraform "init", Terraform will download the required providers. 
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 3.101.0" # Allows as minimum or later. 
        }
        // Additonal providers can be added here if required.
    }
}

// Define 'local' variables used by other resource blocks below. 
// Use 'variables.tf' file to define input variables. 
locals {
  project_name        = "azlab01" // Use this to define a consistant naming method for resources.
  location              = "australiaeast" // Define the default location/region for Azure resources to be created in. 
  az_tags               = {environment = "lab01"} // Define collection of tags that should be assigned to resources. 
}

// Resource Group
// Define a resource type, resource label, and attributes for specific resource. 
// Syntax: resource [resource_type] [object_name]
// Description: Assign a "label" to the resource "object", no relation to "resource:name". 
//              Can be referenced when creating other resources. 
//              Resource labels can be used to reference the resources attribute in another resource definition. 
resource "azurerm_resource_group" "az_rg_01" {
  name      = "${local.project_name}-rg" // Name for the resource inside of Azure. 
  location  = local.location // Use the local variable defined for this parameter.
  tags      = local.az_tags // Read in the 'tags' variable defined in global "variables.tf" file.
}

// Storage Account
resource "azurerm_storage_account" "az_sa_01" {
  name                     = "${local.project_name}sa1"
  resource_group_name      = azurerm_resource_group.az_rg_01.name // Use the above resource group attribute 'name'. 
  location                 = azurerm_resource_group.az_rg_01.location // Leverage the above resource group object attribute 'location'.
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.az_tags // Read in the 'tags' variable defined in the 'local' variable block above.
}

// Networks
resource "azurerm_virtual_network" "vnet_01" {
  name                = "${local.project_name}-vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_rg_01.location // Leverage the above resource group object attribute 'location'.
  resource_group_name = azurerm_resource_group.az_rg_01.name // Use the above resource group attribute 'name'.
}

resource "azurerm_subnet" "subnet_01" {
  name                  = "${local.project_name}-subnet01"
  resource_group_name   = azurerm_resource_group.az_rg_01.name // Use the above resource group attribute 'name'.
  virtual_network_name  = azurerm_virtual_network.vnet_01.name
  address_prefixes      = ["10.0.50.0/24"]
}

resource "azurerm_public_ip" "public_ip_01" {
  name                = "${local.project_name}-pip01"
  location            = azurerm_resource_group.az_rg_01.location
  resource_group_name = azurerm_resource_group.az_rg_01.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic_01" {
  name                = "${local.project_name}-nic01"
  location            = azurerm_resource_group.az_rg_01.location // Leverage the above resource group object attribute 'location'.
  resource_group_name = azurerm_resource_group.az_rg_01.name // Use the above resource group attribute 'name'.
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_01.id
  }
}

resource "azurerm_linux_virtual_machine" "vm01" {
  name                = "${local.project_name}-vm01"
  location            = azurerm_resource_group.az_rg_01.location // Leverage the above resource group object attribute 'location'.
  resource_group_name = azurerm_resource_group.az_rg_01.name // Use the above resource group attribute 'name'.
  size                = "Standard_B1s" // https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_01.id
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
  }
  os_disk {
    name                 = "${local.project_name}-vm01disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}