# Azure Terraform Lab 01 (Basics)
### Example usage of using Terraform to provision resources in Azure.
This example provides the code used for Terraform to connect to Azure using the 'AzureRM' provider.  
Next, using Terraform we can declare the resources in their 'desired state'.  
Once the resources are defined, test the Terraform plan ensuring the output matches intended actions.  
Finally, we can push the plan to Azure and watch the resources as they are provisioned.  

### Guide/Documentation
Review this [guide](docs/Azure_Terraform_Lab01-Basics_Guide.md) for more details. 

## Getting Started
1. Install Terraform
2. Configure Azure Entra ID application registration (service principal). 
3. Modify Terraform code and adjust variables to suit Azure environment (tenant, subscription etc). 
4. Run Terraform plan, verify and apply.

```
> terraform init
> terraform plan
> terraform apply
```

5. Remove all resources when finished.

```
> terraform destroy
```

## File List
* main.tf
    - This file contains the main configuration for your infrastructure, including resource definitions, data sources, and any other configuration elements needed to build your environment using Terraform.
* providers.tf
    - In this file, you define the providers for your Terraform configuration, specifying which cloud or service providers will be used and any relevant configuration details.
* backend.tf
    - Backend configuration file where you specify the backend type (like S3, Azure Blob Storage, etc.) and any necessary settings for storing Terraform state remotely (if required). Leave blank to utilize local storage. 
* variables.tf
    - This file defines input variables for your Terraform configuration, allowing you to parameterize your infrastructure code and make it more reusable and customizable.
* outputs.tf
    - Declare the outputs that you want Terraform to display after applying the configuration, such as IP addresses, URLs, or any other relevant information about your deployed infrastructure.
* az-client-secret
    - Not included, see the provided [guide](docs/Azure_Terraform_Lab01-Basics_Guide.md) on how to configure the Azure connection.
