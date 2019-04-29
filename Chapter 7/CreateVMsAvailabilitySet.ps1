#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group for the Availability Set:
New-AzResourceGroup -Name PacktVMResourceGroup -Location EastUS

#Create an availability set for the VMs:
New-AzAvailabilitySet `
   -Location "EastUS" `
   -Name "PacktVMAvailabilitySet" `
   -ResourceGroupName PacktVMResourceGroup `
   -Sku aligned `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 2

#Set the administrator credentials for the VMs:
$cred = Get-Credential

#Create the two virtual machines inside the Availability Set:
for ($i=1; $i -le 2; $i++)
{
    New-AzVm `
        -ResourceGroupName PacktVMResourceGroup `
        -Name "PacktVM$i" `
        -Location "East US" `
        -VirtualNetworkName "PacktVnet" `
        -SubnetName "PacktSubnet" `
        -SecurityGroupName "PacktNetworkSecurityGroup" `
        -PublicIpAddressName "PacktPublicIpAddress$i" `
        -AvailabilitySetName "PacktVMAvailabilitySet" `
        -Credential $cred
}