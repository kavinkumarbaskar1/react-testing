variable "resource_group_name" {}
variable "location" {}
variable "app_service_environment" {}
variable "storage_account_name" {}
variable "web_app_name" {}
variable "key_vault_name" {}
variable "app_service_plan_name" {}
variable "budget_amount" {}
variable "email_address" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "static_assets" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  access_tier              = "Hot"

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_storage_container" "static_assets_container" {
  name                  = "static-assets"
  storage_account_name  = azurerm_storage_account.static_assets.name
  container_access_type = "blob"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku {
    tier = "PremiumV2"
    size = "P1v2"
    capacity = 1
  }
}

resource "azurerm_app_service" "web_app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on          = true
    http2_enabled      = true
    linux_fx_version   = "NODE|18-lts"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
    "WEBSITE_NODE_DEFAULT_VERSION"   = "18-lts"
  }
}

resource "azurerm_application_insights" "main" {
  name                = "${var.web_app_name}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"

  tenant_id = data.azuread_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azuread_client_config.current.tenant_id
  object_id = azurerm_app_service.web_app.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_monitor_autoscale_setting" "autoscaling" {
  name                = "${var.web_app_name}-autoscale"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  target_resource_id = azurerm_app_service_plan.app_service_plan.id

  profile {
    name = "Autoscale Profile"
    capacity {
      minimum = 1
      maximum = 5
      default = 2
    }

    rule {
      metric_trigger {
        metric_name    = "Percentage CPU"
        metric_resource_type = "Microsoft.Web/serverfarms"
        operator        = "GreaterThan"
        statistic       = "Average"
        threshold       = 75
        time_grain      = "PT1M"
        time_window     = "PT5M"
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }
}

resource "azurerm_network_front_door" "azure_cdn" {
  name                = "frontend-cdn-${var.resource_group_name}"
  resource_group_name = var.resource_group_name

  backend_pool {
    name = "cdn-backend"
    backend {
      address = azurerm_app_service.web_app.default_site_hostname
      priority = 1
      weight = 50
    }
  }
  frontend_endpoint {
    name = "cdn-endpoint"
  }
}

resource "azurerm_budget" "azure_budget" {
  name                = "monthlybudget-frontservices"
  amount              = var.budget_amount
  resource_group_name = var.resource_group_name
  time_grain          = "Monthly"

  notification {
    operator = "GreaterThan"
    threshold = 95
    contact_email = [var.email_address]
    language = "en"
  }
}