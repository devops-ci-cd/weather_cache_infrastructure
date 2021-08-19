output "azure_backend_app_name" {
  value = azurerm_function_app.backend.name
}

output "azure_frontend_app_name" {
  value = azurerm_app_service.frontend.name
}

output "azure_db_server_name" {
  value = azurerm_mssql_server.db_server.name
}

output "azure_db_name" {
  value = azurerm_mssql_database.db.name
}

output "main_rg" {
  value = var.rg
}