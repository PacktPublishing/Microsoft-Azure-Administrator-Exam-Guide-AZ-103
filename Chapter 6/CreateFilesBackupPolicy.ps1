#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
#Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

Select-AzSubscription -SubscriptionId "ca463175-6884-42be-8c17-f5f1abe5a5b0"

#Create a resource group for the Recovery Services Vault:
New-AzResourceGroup -Name PacktRecoveryServicesGroup -Location EastUS

#Create a new Recovery Services Vault
New-AzRecoveryServicesVault -Name PacktFileVault -ResourceGroupName PacktRecoveryServicesGroup -Location EastUS

#You can now set the type of redundancy to use for the vault storage:
$vault1 = Get-AzRecoveryServicesVault -Name PacktFileVault `
    
Set-AzRecoveryServicesBackupProperties -Vault $vault1 `
    -BackupStorageRedundancy GeoRedundant


#store the vault ID in a variable and use it to create the policy
$vaultID = Get-AzRecoveryServicesVault `
    -ResourceGroupName PacktRecoveryServicesGroup `
    -Name PacktFileVault `
    | select -ExpandProperty ID 

#Create a new backup policy 
$packtSchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureFiles"
$packtRetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureFiles"
$afsPol = New-AzRecoveryServicesBackupProtectionPolicy -Name "PacktFSPolicy" `
    -WorkloadType "AzureFiles" `
    -RetentionPolicy $packtRetPol `
    -SchedulePolicy $packtSchPol `
    -VaultId $vaultID `
    -BackupManagementType AzureStorage

#Enable the backup and apply the policy
Enable-AzRecoveryServicesBackupProtection -VaultId $vaultID `
    -Policy $afsPol `
    -Name "azurefileshare" `
    -StorageAccountName "packtfileshare" 