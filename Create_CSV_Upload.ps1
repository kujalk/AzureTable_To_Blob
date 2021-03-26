<#
Purpose - To query Azure Table and upload the CSV file to Blob storage
Parameters - Configuration File
Developer - K.Janarthanan
Date - 25/3/2021

Notes
 - Blog CSV files will be over-written
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
        Connect-AzAccount -Subscription $Config.SubscriptionName -Tenant $Config.TenantID -EA Stop | Out-Null

        $ResourceGP = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $Config.ResourceGroup} 

        if($ResourceGP)
        {
            $ctx = (Get-AzStorageAccount -ResourceGroupName $Config.ResourceGroup -Name $Config.StorageAccountName -EA Stop).context
            $cloudTable = (Get-AzStorageTable -Name $Config.TableName -Context $ctx -EA Stop).CloudTable

            foreach($Item in $Config.PartitionKey)
            {
                Write-Host "`nWorking on partitionkey - $Item" -ForegroundColor Green
                $CSV_File = ("{0}.csv" -f $Item)
                
                Get-AzTableRow -table $cloudTable -PartitionKey $Item -ErrorAction Stop | Export-Csv -NoTypeInformation -Path $CSV_File

                if(Test-Path -Path $CSV_File -PathType Leaf)
                {
                    Write-Host "Uploading file $CSV_File to blobstorage" -ForegroundColor Green
                    Set-AzStorageBlobContent -File $CSV_File -Container $Config.BlobStorageName -Blob $CSV_File -Context $ctx -Force -ErrorAction Stop | Out-Null
                } 
                else 
                {
                    Write-Host "CSV file $CSV_File not found" -ForegroundColor Yellow    
                }      
            }
            
            Write-Host "`nDone with the script" -ForegroundColor Green
        }
        else 
        {
            Write-Host "No resource group found" -ForegroundColor Green
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
}