variable "location" {
  description = "Azure region for the recovery lab."
  type        = string
  default     = "UAE North"
}

variable "resource_group_name" {
  description = "Resource Group containing the lab infrastructure."
  type        = string
  default     = "rg-pg-recovery-lab"
}

variable "server_name_prefix" {
  description = "Prefix used for the globally unique PostgreSQL Flexible Server name."
  type        = string
  default     = "pg-recovery-lab"
}

variable "database_name" {
  description = "PostgreSQL database used by the recovery drill."
  type        = string
  default     = "recoverylab"
}

variable "admin_username" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "pgrecoveryadmin"
}

variable "admin_password" {
  description = "PostgreSQL administrator password. Supplied through TF_VAR_admin_password."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "admin_password must contain at least 12 characters."
  }
}

variable "client_ip" {
  description = "Current public IPv4 allowed through the source server firewall."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask("${var.client_ip}/32"))
    error_message = "client_ip must be a valid IPv4 address."
  }
}
