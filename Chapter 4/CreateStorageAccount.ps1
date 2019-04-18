Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId "********-****-****-****-***********"
New-AzureRmResourceGroup -Name PacktPubStorageAccount -Location "East US"
New-AzureRmStorageAccount -ResourceGroupName PacktPubStorageAccount -AccountName packtpubstorage -Location "East US" -SkuName "Standard_GRS"