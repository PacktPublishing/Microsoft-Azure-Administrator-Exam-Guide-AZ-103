Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#retrieve VNet and subnet configuration
$vnet = Get-AzVirtualNetwork -Name PacktVirtualNetwork -ResourceGroupName PacktVNetResourceGroup
$subnet = Get-AzVirtualNetworkSubnetConfig -Name default -VirtualNetwork $vnet 

#Create a private and public ip address and assign them to the config
$publicIP = New-AzPublicIpAddress `
    -Name PacktPublicIP `
    -ResourceGroupName PacktVNetResourceGroup `
    -AllocationMethod Dynamic `
    -Location EastUS

$IpConfig = New-AzNetworkInterfaceIpConfig `
  -Name PacktPrivateIP `
  -Subnet $subnet `
  -PrivateIpAddress 10.0.0.4 `
  -PublicIPAddress $publicIP `
  -Primary

#Create a network interface and assign the config to it
$NIC = New-AzNetworkInterface `
  -Name PacktNIC `
  -ResourceGroupName PacktVNetResourceGroup `
  -Location EastUS `
  -IpConfiguration $IpConfig