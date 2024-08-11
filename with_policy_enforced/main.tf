# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "eastus"
}


# Below is the code to create a subnet and associate it with a network security group (NSG). That will fail due to policy restrictions.
# Define the existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = "vent1"
  resource_group_name = "az-900" # Replace with your resource group name
}

# Define the existing NSG
data "azurerm_network_security_group" "nsg" {
  name                = "nsg_inbound1"
  resource_group_name = "az-900" # Replace with your resource group name
}

# Create the subnet and associate it with the NSG
resource "azurerm_subnet" "subnet" {
  name                 = "subnet1" # Replace with your subnet name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.91.0/24"] # Replace with your address prefix
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}