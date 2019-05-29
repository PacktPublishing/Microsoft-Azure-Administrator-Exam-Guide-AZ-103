#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group for the Storage account:
New-AzResourceGroup -Name PacktPubStorageAccount -Location EastUS

#create s new storage account
New-AzStorageAccount -ResourceGroupName PacktPubStorageAccount -AccountName packtpubstorage -Location "East US" -SkuName Standard_GRS -Kind StorageV2 -AccessTier Hot