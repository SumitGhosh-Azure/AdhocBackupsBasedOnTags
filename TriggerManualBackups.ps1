Param
(                    
    [Parameter(Mandatory = $true)]                
    $TagName,
    [Parameter(Mandatory = $true)]                
    $NumberOfDaysforRetention

)       
$ErrorActionPreference = "Stop"
$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$Vaults = Get-AzRecoveryServicesVault
try 
{

$VMs = Get-AzResource -Tagname $TagName | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}
foreach ($Vault in $Vaults) 
    {
    Set-AzRecoveryServicesVaultContext -Vault $Vault
    $Containers = Get-AzRecoveryServicesBackupContainer -ContainerType 'AzureVM' -Status 'Registered'
    foreach ($Container in $Containers) 
        {
        foreach ($VM in $VMs) 
            {
            if ($VM.Name -eq $Container.FriendlyName) 
                {
                $Item = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType "AzureVM"
                
                $endDate = (Get-Date).AddDays($NumberOfDaysforRetention).ToUniversalTime()
                $Job = Backup-AzRecoveryServicesBackupItem -Item $Item -ExpiryDateTimeUTC $endDate
                Write-Output "Backup Triggered for VM $($vm.Name)"
                }
            }
        }
    }

}

catch
{
Write-Output "Error occured while triggering manual backup of the VM $($vm.Name) - Exception: $($_.Exception.Message) "  
}