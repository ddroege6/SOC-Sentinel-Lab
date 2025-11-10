variable "subscription_id" {
  description = "Azure subscription ID to deploy into"
  type        = string
}

provider "azurerm" {
  features {}

  # Explicit subscription is more deterministic and avoids the
  # 'subscription ID could not be determined' error.
  subscription_id = var.subscription_id

  # Authentication still uses your `az login` session,
  # so no secrets or credentials are stored here.
}
