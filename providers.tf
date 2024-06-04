// Defines the cloud provider (Azure) configuration.
// Configuration for additonal providers can be added here in separate 'provider' 'locks.
provider "azurerm" {
    features {}
    client_id               = "[snip]" // Azure Entra ID application registration ID (service principal).
    client_secret_file_path = "./az-client-secret" // Path to a file containing the application registration client secret. 
    tenant_id               = "[snip]" // Azure tenant ID
    subscription_id         = "[snip]" // Target Azure subscription to work with.
}
