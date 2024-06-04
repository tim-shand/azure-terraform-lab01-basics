# Terraform: Azure Tutorial and Basic Usage

**Guide to configuring Terraform with Azure using basic examples.** 

## <a name="_toc165673292"></a>**Contents**

[1.0	Overview	](#_toc165673293)

[1.1	Requirements & Prerequisites	](#_toc165673294)

[1.2	Terraform File Types Explained	](#_toc165673295)

[2.0	Install Terraform	](#_toc165673296)

[3.0	Configure Azure Authentication	](#_toc165673297)

[3.1	Authentication Methods	](#_toc165673298)

[3.2	Azure Application Registration (Service Principal)	](#_toc165673299)

[3.3	Subscription & Role Assignment	](#_toc165673300)

[4.0	Terraform Configuration & Execution	](#_toc165673301)

[4.1	Project Files	](#_toc165673302)

[4.2	Terraform Execution	](#_toc165673303)

[4.3	Terraform Destruction (Clean Up)	](#_toc165673304)


## <a name="_toc165673293"></a>**1. Overview**
In this tutorial, we will cover setting up and configuring Terraform to authenticate and manage resources in an existing Azure tenant. 
### <a name="_toc165673294"></a>**1.1 Requirements & Prerequisites**
- **Azure CLI**
  - Used to interface with Azure for authentication and 
  - **Download:** <https://learn.microsoft.com/en-us/cli/azure/install-azure-cli#install>
- **Terraform**
  - Free to use IaC tool.
  - **Download:** https://developer.hashicorp.com/terraform/install
- **Existing Azure tenant with active subscription**
  - Sign up for a free account at <https://portal.azure.com>
- **Code Editor**
  - Ideally with build-in terminal session capabilities. 
  - A popular, and also personal preference of mine, is Visual Studio Code. 
  - **Download:** <https://code.visualstudio.com/download>
- **Terraform Project Files**
  - These can be obtained from this Github repo. 

### <a name="_toc165673295"></a>**1.2 Terraform File Types Explained**
**Configuration Files (Terraform Files)**

Terraform uses configuration files written in HashiCorp Configuration Language (HCL) to define the desired state of infrastructure resources. These files typically have a “.tf” extension and contain declarations of resources, providers, variables, and other settings.

- **Providers:** These specify the cloud or infrastructure platform where resources will be provisioned, such as AWS, Azure, or Google Cloud Platform.
- **Resources:** Resource blocks define the infrastructure components to be created or managed, such as virtual machines, networks, databases, etc. Each resource block includes parameters to configure the resource, such as size, location, and access controls.
- **Variables:** Variables allow users to parameterize their configuration, enabling reusability and flexibility. They can be defined in separate .tf files or provided externally.
- **Modules:** Modules are reusable configurations that encapsulate a set of resources and configurations. They enable modularization and abstraction, simplifying the management of complex infrastructure configurations.

**State File**

Terraform maintains a state file (typically named terraform.tfstate) to keep track of the current state of managed infrastructure. This file contains information about the resources Terraform manages, their attributes, dependencies, and metadata. The state file is crucial for Terraform to understand the existing infrastructure and determine the actions needed to achieve the desired state specified in the configuration files.

- **Remote State:** In production environments, it's recommended to use remote state storage (e.g., Terraform Cloud, AWS S3, Azure Blob Storage) to store the state file securely and enable collaboration among team members. This helps prevent state file corruption and ensures consistency across deployments.

## <a name="_toc165673296"></a>**2.0 Install Terraform**
**Note:** If you are using MacOS or Linux, refer to the link in section 1.1 to determine installation method. Once installed, there is nothing further required in this section as Terraform will likely already be accessible in the PATH environment variable. Proceed to the next section. 

**Windows Enviroment Variable**   
Download from the vendor (Hashicorp) website using the link provided above.   
The downloaded zip file contains just a license file and the Terraform executable. It will need to be extracted and saved to an appropriate location. 

Once the file has been extracted and moved, we will need to add it to the environment variable “PATH” to allow us to execute Terraform from command line without needed to be in the directory where it is located. 

Open “**Settings**” and navigate to “**System > About**”. Select “**Advanced System Settings**”.   
Select the “**Advanced**” tab and click “**Environment Variables**”.   

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.002.png)

Select the entry listed as “**Path**” under the “**System Variables**” section and click “**Edit**”.   
In the new pop-up window, click “**New**” and add the path to the Terraform executable file.   

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.003.png)

To confirm that the Terraform path is now accessible, open a terminal session and execute the following:

**Command:** `terraform -version`

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.004.png)

With Terraform now in place, we can proceed to configure Azure. 

## <a name="_toc165673297"></a>**3.0 Configure Azure Authentication**
### <a name="_toc165673298"></a>**3.1 Authentication Methods**
Authentication to Azure via Terraform can be performed using several methods. 

**Azure CLI Authentication**   
Terraform can use the Azure CLI credentials for authentication. When you run “az login” to authenticate with Azure CLI, Terraform can use those credentials to authenticate as well.

**Managed Service Identity (MSI)**   
Azure VMs and Azure App Service instances can be configured with Managed Service Identity, allowing Terraform to authenticate using these identities without needing explicit credentials.

**Service Principal Authentication (App Registration)**   
Service Principal authentication involves creating an Azure Active Directory (AAD) application registration, which generates a service principal. Terraform can then use the client ID, client secret, and tenant ID of this service principal for authentication.

**Environment Variables**   
Terraform can authenticate using Azure environment variables:
- ARM\_CLIENT\_ID: The client ID of the Azure AD application.
- ARM\_CLIENT\_SECRET: The client secret of the Azure AD application.
- ARM\_TENANT\_ID: The tenant ID where the Azure AD application is registered.
- ARM\_SUBSCRIPTION\_ID: The subscription ID to use.

### <a name="_toc165673299"></a>**3.2 Azure Application Registration (Service Principal)**
In this guide, we will be using an Azure Application Registration, otherwise known as a “Service Principal”. There four components required for this method to be successful:

- **Directory (tenant) ID**
  - The existing ID assigned to the Azure tenant. 
- **Subscription ID**
  - This is the ID of the current active subscription that the resources will belong to. 
- **Application (client) ID**
  - The ID assigned to an Application Registration (service principal). 
  - Requires creation via the Azure Portal. 
- **Client Secret**
  - Credential used by an Azure application registration to authenticate and authorize itself when accessing Azure resources programmatically. 
- **Role Assignment**
  - A role must be assigned to the service principal in order to grant permissions to create/delete Azure resources. 

**Note:** If you do not have an existing Azure tenant, you can sign up for free using a new or existing Microsoft account. 

Log in to the Azure portal and navigate to Entra ID. Using the side panel menu, select “**Microsoft Entra ID**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.005.png)

From the left hand side panel, locate and select the “**App Registrations**” blade. Click “**New Registration**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.006.png)

Configure the new application registration as follows and click “**Register**”:

- **Name**
  - Specify a new name for this service principal. 
  - The name doesn’t matter in relation to Terraform as it uses the IDs instead. 
- **Support Account Types**
  - Depending on your existing tenant configuration, select the option that best suits your environment. 
  - For most use cases, the single tenant option will work fine. 
- **Redirect URI (Optional)**
  - Select the option “Web” and leave the path blank as this is not used or required. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.007.png)

Select your new application registration to display the properties.   
Copy both the “**Application (client) ID**” and “**Directory (tenant) ID**” values and paste them temporarily into a Notepad file for use in later steps. 

Once the values have been stored, from the side menu under “**Manage**”, select “**Certificates & Secrets**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.008.png)

From within the “**Certificates & Secrets**” blade, select the section “**Client Secrets**” and click “**New client secret**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.009.png)

Add a description for the new secret and select a time period for the secret to be valid (default is 6 months). Click “**Add**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.010.png)

The new client secret will be listed. The value of the secret will only be shown once, so make sure to copy it and store it securely. 

**Note:** Once clicked away from the screen, the value will never be shown again and a new client secret will need to be created. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.011.png)

We now have three of the required values for the Terraform Azure authentication. The next step is to assign an appropriate role to the service principal for the subscription and collect the subscription ID. 

### <a name="_toc165673300"></a>**3.3 Subscription & Role Assignment**
Navigate to the “**Subscriptions**” blade and select your active subscription. Take note the “**Subscription ID**” as that will be required later. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.012.png)

From within the “**Subscriptions**” blade, select “**Access Control (IAM)**” from the left side panel.   
Using the “**Add**” dropdown menu, select “**Add Role Assignment**”. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.013.png)

From within the “**Role Assignment**” window, select the tab labelled “**Privileged Administrator Roles**”.   
Choose a role that is appropriate for the level of control Terraform will require. 

**Note:** In the case of this example, the role “**Contributor**” has been assigned to allow access to interact with all resource types. More granular control can be achieved using assignments from the “**Job Function Roles**” tab. 

Click “**Next**”.

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.014.png)

In the “**Members**” section, select the option “**User, group, or service principal**”. Click “**Select Members**”.   
Searching for the service principal by name should display a result.   
Select the object and click “**Select**”. On the next screen, click “**Review + Assign**”.   

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.015.png)


## <a name="_toc165673301"></a>**4.0 Terraform Configuration & Execution**
### <a name="_toc165673302"></a>**4.1 Project Files**
As with other types of coding projects, there are many ways to achieve the same result.   
With Terraform, this can be the case as different file structures and directory layouts can be used that result in the same final product.   

For the context of this project, we will be keeping it simple and using a flat file/directory structure using a locally stored state file.  

Review the code in the project files and make changes where required to suit your local and Azure environments. 

- **main.tf**
  - This file contains the main configuration for your infrastructure, including resource definitions, data sources, and any other configuration elements needed to build your environment using Terraform.
  - The first block defines the “Required Providers”, in this case for Azure – AzureRM. This section specifies the source and minimum version of that provider required. Providers are downloaded during the initial Terraform “init” operation.

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.016.png)

- The second block defines variables known as “locals”. These are variables specific to the current file and can be referenced by declared resources in that same file. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.017.png)

- The remainder of the main.tf file declares the various resources such as resource group, network, network interfaces and virtual machine configuration. 
- **providers.tf**
  - In this file, you define the providers for your Terraform configuration, specifying which cloud or service providers will be used and any relevant configuration details.
  - Replace the example values with the values obtained from your own Azure tenancy. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.018.png)

- **backend.tf**
  - Backend configuration file where you specify the backend type (like S3, Azure Blob Storage, etc.) and any necessary settings for storing Terraform state remotely (if required). Leaving this file blank will utilize local storage instead. 
- **variables.tf**
  - This file defines *input* variables for your Terraform configuration, allowing you to parameterize your infrastructure code and make it more reusable and customizable.
  - If no input variables are required, you can leave this blank and use local variables inside the main.tf file. 
- **outputs.tf**
  - Declare the outputs that you want Terraform to display after applying the configuration, such as IP addresses, URLs, or any other relevant information about your deployed infrastructure. If no output values are required leave this file blank. 
  - In this example, we will output the public IP address of the VM created. 
- **az-client-secret**
  - This is an extension-less file that will contain the client secret created earlier in a text/string format. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.019.png)

### <a name="_toc165673303"></a>**4.2 Terraform Execution**
Once the Terraform files have been reviewed and modified with the necessary variables, proceed to run the first Terraform command:   
`terraform init`

This command will analyze the declared configuration in the Terraform files and download and providers listed in the “required\_providers” section of the main.tf file. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.020.png)

To review what changes will be made, execute the `terraform plan` command.   
Each time this command is run, Terraform will analyse the content of the TF files and compare with the state file to determine which actions need to be taken. 

**Note:** During a first run, there is no state file to compare with, therefore Terraform will attempt to create all resources defined. 

**Command:** `terraform plan`

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.021.png)

The output from the `terraform plan` command shows the number of resources that will be created.   
If any misconfiguration or invalid declarations are made, Terraform will complain and advise on what sections have failed validation.   
Fix any reported issues and re-run the “terraform plan” command.   

Once the plan can be run without errors, and the proposed changes are correctly listed, execute the following command to tell Terraform to implement the changes:

**Command:** `terraform apply`

Enter “yes” at the confirmation prompt to continue.   
Terraform will now proceed to create the resources defined in the main.tf file. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.022.png)

Since we defined an “output” in the “outputs.tf” file, once Terraform has completed its implementation, the desired output will be displayed to the screen. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.023.png)

We can now review the resources in the Azure portal. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.024.png)

### <a name="_toc165673304"></a>**4.3 Terraform Destruction (Clean Up)**
**Warning:** This command will delete all resources that were created by resource blocks defined in the Terraform state file.   
Resources in Azure that were created manually or by other means will remain unaffected.   

To clean-up and remove all Terraform created resources, execute the following command:   
**Command:** `terraform destroy`

Enter “yes” at the confirmation prompt to proceed. 

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.025.png)

![ ](images/Aspose.Words.9f44d427-ebf6-43ec-8ad4-90dd30cc2a62.026.png)

Complete. All resources have been removed. 
