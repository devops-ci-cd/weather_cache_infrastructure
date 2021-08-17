terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">2.46.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "__terraformstorageaccount__"
      container_name       = "terraform"
      key                  = "terraform.tfstate"
	  access_key  = "__storagekey__"
  }
}



provider "azurerm" {
  features {}
  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

resource "random_uuid" "az-id" {
}

resource "azurerm_mssql_server" "db_server" {
  name                         = "${var.prefix}-db-server-${random_uuid.az-id.result}"
  resource_group_name          = var.rg
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password
  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }

}

# Allow Azure services and resources to access this server
resource "azurerm_mssql_firewall_rule" "fw" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.db_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "db" {
  name           = "${var.prefix}-db-${random_uuid.az-id.result}"
  server_id      = azurerm_mssql_server.db_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  sku_name       = "GP_S_Gen5_1"
  min_capacity   = 0.5
  zone_redundant = false
  storage_account_type = "LRS"
  auto_pause_delay_in_minutes = 60

  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }

}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.prefix}-ASP-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  
  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }
}

resource "azurerm_function_app" "backend-query" {
  name                       = "${var.prefix}-queries-${random_uuid.az-id.result}"
  location                   = var.location
  resource_group_name        = var.rg
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  os_type                    = "linux"

  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }
  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = "",
    APPLICATIONINSIGHTS_CONNECTION_STRING = "",
    DB_USER = var.administrator_login,
    azure_db_name = azurerm_mssql_database.db.name,
    azure_db_server_name = azurerm_mssql_server.db_server.name,
    password = var.administrator_password,
    SERVICEBUS_ENDPOINT = ""
  }

  depends_on = [
    azurerm_app_service_plan.asp,
    azurerm_servicebus_queue.queue,
  ]
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "${var.prefix}-sb-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Basic"

  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }
}

resource "azurerm_servicebus_queue" "queue" {
  name                = "${var.prefix}-queue-${random_uuid.az-id.result}"
  resource_group_name = var.rg
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name
  
  max_size_in_megabytes = 1024
  max_delivery_count = 10
  # lock_duration = 30
  enable_partitioning = false
  
  depends_on = [
    azurerm_servicebus_namespace.sb_namespace,
  ]
}


output "azure_app_name" {
  value = azurerm_function_app.backend-query.name
}