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
