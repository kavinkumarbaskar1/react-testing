variable "resource_group_name" {
  description = "The name of the resource group to be created"
  type        = string
}

variable "location" {
  description = "Azure location to deploy resources"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Azure storage account"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the App Service plan"
  type        = string
}

variable "web_app_name" {
  description = "The name of the web application"
  type        = string
}

variable "key_vault_name" {
  description = "The name of the Azure Key Vault"
  type        = string
}

variable "budget_amount" {
  description = "Budget amount for Azure cost management"
  type        = number
}

variable "email_address" {
  description = "Email address for budget notifications"
  type        = string
}