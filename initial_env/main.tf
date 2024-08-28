# create a virtual network and a subnet in us east region and associate it with a network security group
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
# Data source to fetch the policy definition
data "azurerm_policy_definition" "subnet_nsg_policy" {
  display_name = "Subnets should be associated with a Network Security Group"
}

resource "azurerm_resource_group" "rg" {
  name     = "az-900"
  location = "eastus"
}

# Policy assignment at the resource group level
resource "azurerm_resource_group_policy_assignment" "subnet_nsg_assignment" {
  name                 = "subnet-nsg-policy-assignment"
  policy_definition_id = data.azurerm_policy_definition.subnet_nsg_policy.id
  resource_group_id    = azurerm_resource_group.rg.id

  parameters = <<PARAMETERS
{
  "effect": {
    "value": "Deny" 
  }
}
PARAMETERS
}

# create a virtual network called vent1
resource "azurerm_virtual_network" "vnet" {
  name                = "vent1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}


# create a network security group called nsg_inbound2
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg_inbound1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # create a network security rule called allow_ssh
  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


