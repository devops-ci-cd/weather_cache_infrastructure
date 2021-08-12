terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">2.46.0"
    }
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_mssql_server" "db_server" {
  name                         = "${var.prefix}-db-server"
  resource_group_name          = var.rg
  location                     = var.location
  version                      = "12.0"
  # get from the vault
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-adsfasdfasdf-p455wasdfasdfadsasdf0rd"

  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }

}

resource "azurerm_mssql_database" "db" {
  name           = "${var.prefix}-db"
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
