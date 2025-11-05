output "resource_group_id" {
  value = azurerm_resource_group.main.id
  description = "ID of the created Resource Group."
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.app_service_plan.id
  description = "ID of the created App Service Plan."
}

output "web_app_url" {
  value = azurerm_app_service.web_app.default_site_hostname
  description = "URL of the deployed Web App."
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
  description = "Name of the Azure Storage Account."
}

output "blob_container_url" {
  value = azurerm_storage_container.blob_container.id
  description = "ID of the created Blob Container."
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
  description = "Address space of the created Virtual Network."
}