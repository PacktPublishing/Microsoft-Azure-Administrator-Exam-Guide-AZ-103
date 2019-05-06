#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group for the VNet:
New-AzResourceGroup -Name PacktVNetServicesGroup -Location EastUS

#Create the VNet
$virtualNetwork = New-AzVirtualNetwork `
  -ResourceGroupName PacktVNetServicesGroup `
  -Location EastUS `
  -Name PacktVirtualNetwork `
  -AddressPrefix 10.0.0.0/16

#Create the Subnet
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name default `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork

#Accociate the subnet to the virtual network
$virtualNetwork | Set-AzVirtualNetwork
