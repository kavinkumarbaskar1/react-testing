variable "resource_group_name" {
  type        = string
  default     = "my-resource-group"
  description = "Name of the Azure Resource Group to create."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region where the resources will be created."
}

variable "app_service_plan_name" {
  type        = string
  default     = "my-app-service-plan"
  description = "The name of the App Service Plan."
}

variable "app_name" {
  type        = string
  default     = "my-web-app"
  description = "The name of the Web App."
}

variable "storage_account_name" {
  type        = string
  default     = "mystorageaccount"
  description = "The name of the Storage Account."
}

variable "blob_container_name" {
  type        = string
  default     = "static-assets"
  description = "The name of the Blob Container for static assets."
}

variable "vnet_name" {
  type        = string
  default     = "my-vnet"
  description = "The name of the Virtual Network."
}