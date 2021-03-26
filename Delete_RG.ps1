<#
Purpose - To delete the resource group
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

    $Config = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json

    if(($Config.SubscriptionName -ne $null) -and ($Config.ResourceGroup -ne $null))
    {
        Write-Host "Connecting to Azure" -ForegroundColor Green
        Connect-AzAccount -Subscription $Config.SubscriptionName -Tenant $Config.TenantID

        Write-Host "Going to delete the resource group" -ForegroundColor Green

        $ResourceGP = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $Config.ResourceGroup} 
        if($ResourceGP)
        {
            Remove-AzResourceGroup -ResourceGroupName $Config.ResourceGroup -Confirm:$false -Force | Out-Null
            Write-Host "Deleted the Resource Group" -ForegroundColor Green
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