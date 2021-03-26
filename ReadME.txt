Purpose - To move the data from Azure Table storage to Azure Blob container
Developer - Janarthanan
Instructions -

[1] Install the following modules
    AZ
    AZTable

[2] Update the values in Config file
 - Resource group - Where stroage account is created and Azure Table is created

[3] Scripts and Purposes
 - Create_Table - This will create resource group, blob, Azure Table and sample data
 - Create_CSV_Upload.ps1 - To move data from Azure Table storage to Azure Blob
 - Delete_RG - To delete the resource group. This will delete all the resources deployed previously
