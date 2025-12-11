# Terraform configuration for Azure infrastructure

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "react_testing_rg" {
  name     = "react-app-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "react_vnet" {
  name                = "react-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
}

resource "azurerm_subnet" "react_subnet" {
  name                 = "react-subnet"
  resource_group_name  = azurerm_resource_group.react_testing_rg.name
  virtual_network_name = azurerm_virtual_network.react_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_app_service_plan" "react_plan" {
  name                = "react-app-plan"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
  os_type             = "Linux"
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "react_app_service" {
  name                = "react-app-service"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
  app_service_plan_id = azurerm_app_service_plan.react_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

resource "azurerm_storage_account" "react_storage" {
  name                     = "reactstorageaccount"
  resource_group_name      = azurerm_resource_group.react_testing_rg.name
  location                 = azurerm_resource_group.react_testing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "react_container" {
  name                  = "react-container"
  storage_account_name  = azurerm_storage_account.react_storage.name
  container_access_type = "blob"
}

resource "azurerm_key_vault" "react_key_vault" {
  name                = "react-keyvault"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name

  sku_name = "standard"
  tenant_id = "your-tenant-id"
}

resource "azurerm_application_gateway" "react_gateway" {
  name                = "app-gateway"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.react_subnet.id
  }
}

resource "azurerm_log_analytics_workspace" "react_logs" {
  name                = "react-log-workspace"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "react_insights" {
  name                = "react-app-insights"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
  application_type    = "web"
}

resource "azurerm_monitor_autoscale_setting" "react_autoscale" {
  name                = "autoscale-settings"
  location            = azurerm_resource_group.react_testing_rg.location
  resource_group_name = azurerm_resource_group.react_testing_rg.name
  target_resource_id  = azurerm_app_service.react_app_service.id

  profile {
    name = "defaultProfile"

    capacity {
      minimum = "1"
      maximum = "10"
      default = "1"
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_app_service.react_app_service.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 75
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_app_service.react_app_service.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 25
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}