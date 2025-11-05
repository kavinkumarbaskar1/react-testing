terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group to create."
}

variable "location" {
  type        = string
  description = "Azure region where the resources will be created."
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service Plan."
}

variable "app_name" {
  type        = string
  description = "The name of the Web App."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "blob_container_name" {
  type        = string
  description = "The name of the Blob Container for static assets."
}

variable "vnet_name" {
  type        = string
  description = "The name of the Virtual Network."
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on       = true
    linux_fx_version = "DOTNETCORE|6.0"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_container" {
  name                  = var.blob_container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.app_service_plan.id
}

output "web_app_url" {
  value = azurerm_app_service.web_app.default_site_hostname
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "blob_container_url" {
  value = azurerm_storage_container.blob_container.id
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}