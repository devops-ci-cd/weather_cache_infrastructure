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
	  access_key  = "__storage-account-access-key__"
  }
}



provider "azurerm" {
  features {}
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
    owner = var.owner
    env = var.environment
  }

}

# Allow Azure services and resources to access this server
resource "azurerm_mssql_firewall_rule" "fw" {
  name             = "AllowAzureServices"
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
    owner = var.owner
    env = var.environment
  }

  depends_on = [
    azurerm_mssql_server.db_server,
  ]
}

resource "azurerm_application_insights" "backend" {
  name                = "${var.prefix}-backend-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  application_type    = "web"

  tags = {
    owner = var.owner
    env = var.environment
  }
}

resource "azurerm_app_service_plan" "backend" {
  name                = "${var.prefix}-backend-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  
  tags = {
    owner = var.owner
    env = var.environment
  }
}

resource "azurerm_function_app" "backend" {
  name                       = "${var.prefix}-backend-${random_uuid.az-id.result}"
  location                   = var.location
  resource_group_name        = var.rg
  app_service_plan_id        = azurerm_app_service_plan.backend.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  os_type                    = "linux"
  version                    = "~3"

  site_config {
      linux_fx_version = "PYTHON|3.7"
  }

  tags = {
    owner = var.owner
    env = var.environment
  }
  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.backend.instrumentation_key,
    FUNCTIONS_WORKER_RUNTIME = "python",
    DB_USER = var.administrator_login,
    azure_db_name = azurerm_mssql_database.db.name,
    azure_db_server_name = "${azurerm_mssql_server.db_server.name}.database.windows.net",
    password = var.administrator_password,
    SERVICE_BUS_CONNECTION_STR = azurerm_servicebus_namespace_authorization_rule.auth.primary_connection_string,
    SERVICE_BUS_QUEUE_NAME = azurerm_servicebus_queue.queue.name  
  }

  depends_on = [
    azurerm_app_service_plan.backend,
    azurerm_servicebus_queue.queue,
    azurerm_application_insights.backend,
  ]
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "${var.prefix}-sb-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Basic"

  tags = {
    owner = var.owner
    env = var.environment
  }
}

resource "azurerm_servicebus_namespace_authorization_rule" "auth" {
  name                = "${var.prefix}-sb-rule"
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name
  resource_group_name = var.rg

  listen = true
  send   = true
  manage = false
}

resource "azurerm_servicebus_queue" "queue" {
  name                = "${random_uuid.az-id.result}"
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

resource "azurerm_application_insights" "frontend" {
  name                = "${var.prefix}-frontend-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  application_type    = "web"
  
  tags = {
    owner = var.owner
    env = var.environment
  }
  
}

resource "azurerm_app_service_plan" "frontend" {
    name                = "${var.prefix}-frontend-${random_uuid.az-id.result}"
    location            = var.location
    resource_group_name = var.rg
    kind                = "Linux"
    reserved            = true

    sku {
      tier = "Basic"
      size = "B1"
    }
    
  tags = {
    owner = var.owner
    env = var.environment
  }
}

resource "azurerm_app_service" "frontend" {
  name                = "${var.prefix}-frontend-${random_uuid.az-id.result}"
  location            = var.location
  resource_group_name = var.rg
  app_service_plan_id = azurerm_app_service_plan.frontend.id

  
  site_config {
    linux_fx_version = "PYTHON|3.7"
  }

  tags = {
    owner = var.owner
    env = var.environment
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.frontend.instrumentation_key,
    DB_USER = var.administrator_login,
    azure_db_name = azurerm_mssql_database.db.name,
    azure_db_server_name = "${azurerm_mssql_server.db_server.name}.database.windows.net",
    password = var.administrator_password,
    SERVICE_BUS_CONNECTION_STR = azurerm_servicebus_namespace_authorization_rule.auth.primary_connection_string,
    SERVICE_BUS_QUEUE_NAME = azurerm_servicebus_queue.queue.name,
    SCM_DO_BUILD_DURING_DEPLOYMENT = 1
  }

  depends_on = [
    azurerm_app_service_plan.frontend,
    azurerm_servicebus_queue.queue,
    azurerm_application_insights.frontend,
  ]
  
}
