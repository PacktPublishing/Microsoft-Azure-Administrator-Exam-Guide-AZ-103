#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Retrieve Storage account
$accountObject = Get-AzStorageAccount -ResourceGroupName "PacktPubStorageAccount" -AccountName "packtpubstorage"

#Get the context
$Context = $accountObject.Context

#Create a new blob container
new-AzStoragecontainer -Name "packtblobcontainerps" -Context $Context -Permission blob