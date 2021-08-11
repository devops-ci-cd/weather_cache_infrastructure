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
  min_capacity   = 1
  zone_redundant = false
  storage_account_type = "LRS"
  auto_pause_delay_in_minutes = 60

  #   extended_auditing_policy {
  #   storage_endpoint                        = "polyarush-sa01-ep1.nic.ad2e3747-8849-4e2c-a523-1cd8bed2d1ef"
  #   storage_account_access_key              = "7BIEpmHYmlm/NtaomXQ9mtWs+Eh5djeFR/dYRSWmpVCjyOl4TXngGF27Kiu4/TEeDStOnNUtc4qTIb0vJKpw4w=="
  #   storage_account_access_key_is_secondary = true
  #   retention_in_days                       = 6
  # }


  tags = {
    owner = "Evgeny_Polyarush@epam.com"
  }

}
