resource "random_string" "server_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = "azure-postgresql-recovery-drill"
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "azurerm_postgresql_flexible_server" "source" {
  name                = "${var.server_name_prefix}-${random_string.server_suffix.result}"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  version = "17"

  administrator_login               = var.admin_username
  administrator_password_wo         = var.admin_password
  administrator_password_wo_version = 1

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled = true

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  tags = {
    project     = "azure-postgresql-recovery-drill"
    role        = "source"
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "azurerm_postgresql_flexible_server_database" "lab" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.source.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "current_client" {
  name             = "allow-current-client"
  server_id        = azurerm_postgresql_flexible_server.source.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}
