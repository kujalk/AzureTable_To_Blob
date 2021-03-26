<#
Purpose - To create following resources
        [1] Resource Group
        [2] Storage Account
        [3] Azure Storage Table - With sample data
        [4] Azure Blob container
Parameters - Configuration File
Developer - K.Janarthanan
Date - 25/3/2021
#>

Param(
    [Parameter(Mandatory)]
    [string]$ConfigFile
)

try 
{
    Import-Module -Name Az.Accounts -ErrorAction Stop
    Import-Module -Name Az.Resources -ErrorAction Stop
    Import-Module -Name Az.Storage -ErrorAction Stop
    Import-Module -Name AzTable -ErrorAction Stop

    $Config = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json

    if(($Config.SubscriptionName -ne $null) -and ($Config.ResourceGroup -ne $null))
    {
        Write-Host "Connecting to Azure" -ForegroundColor Green
        Connect-AzAccount -Subscription $Config.SubscriptionName -Tenant $Config.TenantID

        $ResourceGP = Get-AzResourceGroup | ? {$_.ResourceGroupName -eq $Config.ResourceGroup} 
        if($ResourceGP -eq $null)
        {
            Write-Host "Resource group not found. Therefore will create it" -ForegroundColor Green
            New-AzResourceGroup -ResourceGroupName $Config.ResourceGroup -Location $Config.Region -EA Stop
            Write-Host "Created new Resource Group" -ForegroundColor Green

            Write-Host "Going to create Storage Account" -ForegroundColor Green
            $storageAccount = New-AzStorageAccount -ResourceGroupName $Config.ResourceGroup `
            -Name $Config.StorageAccountName`
            -Location $Config.Region `
            -SkuName Standard_LRS `
            -Kind Storage -EA Stop

            Write-Host "Created Storage Account" -ForegroundColor Green

            Start-Sleep -Seconds 5
            $ctx = (Get-AzStorageAccount -ResourceGroupName $Config.ResourceGroup -Name $Config.StorageAccountName).context
            
            Write-Host "Going to create Azure Table" -ForegroundColor Green
            New-AzStorageTable -Name $Config.TableName -Context $ctx -EA Stop
            Write-Host "Created Azure Table" -ForegroundColor Green

            Write-Host "Adding Entries to Table" -ForegroundColor Green
            $cloudTable = (Get-AzStorageTable -Name $Config.TableName -Context $ctx).CloudTable

            $partitionKey1 = "partition1"
            $partitionKey2 = "partition2"

            # add sample data 
            Add-AzTableRow `
                -table $cloudTable `
                -partitionKey $partitionKey1 `
                -rowKey ("CA") -property @{"username"="Chris";"userid"=1}

            Add-AzTableRow `
                -table $cloudTable `
                -partitionKey $partitionKey2 `
                -rowKey ("NM") -property @{"username"="Jessie";"userid"=2}

            Add-AzTableRow `
                -table $cloudTable `
                -partitionKey $partitionKey1 `
                -rowKey ("WA") -property @{"username"="Christine";"userid"=3}

            Add-AzTableRow `
                -table $cloudTable `
                -partitionKey $partitionKey2 `
                -rowKey ("TX") -property @{"username"="Steven";"userid"=4}

            Write-Host "Added entries to Table" -ForegroundColor Green

            Write-Host "Going to create Blob storage" -ForegroundColor Green
            New-AzStorageContainer -Name $Config.BlobStorageName -Context $ctx -Permission blob -EA Stop
            Write-Host "Created Blob storage" -ForegroundColor Green
        }

        else 
        {
            throw "Resource group is already found"    
        }

    }
    else 
    {
        throw "SubscriptionName and ResourceGroup are mandatory"    
    }

}
catch 
{
    Write-Host "Error - $_" -ForegroundColor Red  
    Write-Host "`nDeleting the Resource Group" -ForegroundColor Red

    $ResourceGP = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $Config.ResourceGroup} 
    if($ResourceGP)
    {
        Remove-AzResourceGroup -ResourceGroupName $Config.ResourceGroup -Confirm:$false -Force
        Write-Host "Deleted the Resource Group" -ForegroundColor Red
    }
}