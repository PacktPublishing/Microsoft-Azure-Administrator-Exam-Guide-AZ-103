#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Retrieve Stroage account
Get-AzStorageAccount -ResourceGroupName "PacktPubStorageAccount" -AccountName "packtpubstorage"

#Create a new blob container
New-AzureStorageContainer -Name "packtblobcontainerps" -Permission Blob

#New-AzureRmStorageContainer -StorageAccount $accountObject -ContainerName "packtblobcontainerps" -PublicAccess Blob