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
$vault1 = Get-AzRecoveryServicesVault `
    -Name PacktFileVault `
    | Set-AzRecoveryServicesVaultContext 
    
Set-AzRecoveryServicesBackupProperties -Vault $vault1 `
    -BackupStorageRedundancy GeoRedundant

#Create a new backup policy 
$packtSchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureFiles"
$packtRetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureFiles"
New-AzRecoveryServicesBackupProtectionPolicy `
    -Name "PacktFSPolicy" `
    -WorkloadType "AzureFiles" `
    -RetentionPolicy $packtRetPol `
    -SchedulePolicy $packtSchPol

#Store the policy in a variable
$afsPol =  Get-AzRecoveryServicesBackupProtectionPolicy -Name "PacktFSPolicy"

#Enable the backup and apply the policy
Enable-AzRecoveryServicesBackupProtection -StorageAccountName "packtfileshare" `
    -Name "PacktFSPolicy" `
    -Policy $afsPol