########################################
# Variables
########################################

variable "location" {
  description = "Azure region for the lab"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Name prefix for lab resources"
  type        = string
  default     = "ftc-soc-lab"
}

########################################
# Resource Group
########################################

resource "azurerm_resource_group" "this" {
  name     = "${var.project_name}-rg"
  location = var.location

  tags = {
    project = var.project_name
    owner   = "dylan-droege"   # or whatever you want
    env     = "lab"
  }
}

########################################
# Log Analytics Workspace
########################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project_name}-law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Sentinel-friendly SKU
  sku = "PerGB2018"

  # 90 days is free for Analytics logs once Sentinel is enabled,
  # and is a good lab default.
  retention_in_days = 90

  tags = {
    project = var.project_name
    env     = "lab"
  }
}

########################################
# Microsoft Sentinel Onboarding
########################################

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id = azurerm_log_analytics_workspace.this.id

  depends_on = [azurerm_log_analytics_workspace.this]
}
