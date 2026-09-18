output "resource_group_name" {
  description = "Resource Group containing the recovery lab."
  value       = azurerm_resource_group.lab.name
}

output "source_server_name" {
  description = "Source PostgreSQL Flexible Server name."
  value       = azurerm_postgresql_flexible_server.source.name
}

output "source_server_fqdn" {
  description = "Source PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.source.fqdn
}

output "database_name" {
  description = "Recovery drill database name."
  value       = azurerm_postgresql_flexible_server_database.lab.name
}

output "admin_username" {
  description = "PostgreSQL administrator username."
  value       = var.admin_username
}

output "source_firewall_rule_name" {
  description = "Firewall rule allowing the current client IPv4."
  value       = azurerm_postgresql_flexible_server_firewall_rule.current_client.name
}
