terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.9.0"
    }
  }
  cloud {
    organization = "royaltyTEQ"
    workspaces {
      name = "100Days"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "Learning_RG" {
  name     = "100_Days_of_Learning"
  location = "uksouth"
}

resource "azurerm_monitor_action_group" "RTDS_AG" {
  name                = "RTDS Action Group"
  resource_group_name = azurerm_resource_group.Learning_RG.name
  short_name          = "RTDS_AG"
}

resource "azurerm_consumption_budget_subscription" "RTDS_Budget" {
  name            = "RTDS_Budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 100
  time_grain = "Monthly"

  time_period {
    start_date = "2022-06-01T00:00:00Z"
    end_date   = "2025-07-01T00:00:00Z"
  }

  filter {    
    tag {
      name = "Subcription Budget"
      values = [
        "RTDS_Budget",        
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"
    threshold_type = "Forecasted"

    contact_emails = [
      "onome.aniyeye@gmail.com",
      "onome.aniyeye@royaltyTEQ.com",
    ]

    contact_groups = [
      azurerm_monitor_action_group.RTDS_AG.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [
      "onome.aniyeye@gmail.com",
      "onome.aniyeye@royaltyTEQ.com",
    ]
  }
}