#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group for the Recovery Services Vault:
New-AzResourceGroup -Name PacktRecoveryServicesGroup -Location EastUS

#Create a new Recovery Services Vault
New-AzRecoveryServicesVault -Name PacktFileVault -ResourceGroupName PacktRecoveryServicesGroup -Location EastUS

#You can now set the type of redundancy to use for the vault storage:
$vault1 = Get-AzRecoveryServicesVault -Name PacktFileVault
    
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
    -Name "packtfileshare" `
    -StorageAccountName "packtfileshare"

#Schedule an on-demand job
#Retrieve the backup container:
$afsPacktContainer = Get-AzRecoveryServicesBackupContainer -FriendlyName "packtfileshare" `
    -ContainerType AzureStorage `
    -VaultId $vaultID

#Retrieve the backup item from the container
$afsPacktBackupItem = Get-AzRecoveryServicesBackupItem `
    -Container $afsPacktContainer `
    -WorkloadType "AzureFiles" `
    -Name "packtfileshare" `
    -VaultId $vaultID

#Schedule the job
$job = Backup-AzRecoveryServicesBackupItem -Item $afsPacktBackupItem `
    -VaultId $vaultID


#Create a list of recovery points
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $afsPacktBackupItem `
    -StartDate $startdate.ToUniversalTime() `
    -EndDate $enddate.ToUniversalTime() `
    -VaultId $vaultID

$rp[0] | fl

#Set Vault context
Get-AzRecoveryServicesVault -Name "PacktFileVault" | Set-AzRecoveryServicesVaultContext

#Restore backup to the original location
Restore-AzRecoveryServicesBackupItem `
    -RecoveryPoint $rp[0] `
    -TargetStorageAccountName "packtfileshare" `
    -TargetFileShareName "packtfileshare" `
    -TargetFolder "AzureFS_restored" `
    -ResolveConflict Overwrite
   