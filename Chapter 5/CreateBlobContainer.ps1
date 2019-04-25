Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId "********-****-****-****-***********"
$accountObject = Get-AzureRmStorageAccount -ResourceGroupName "PacktPubStorageAccount" -AccountName "packtpubstorage"
New-AzureRmStorageContainer -StorageAccount $accountObject -ContainerName "packtblobcontainerps" -PublicAccess Blob