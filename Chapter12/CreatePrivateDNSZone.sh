#Create a resource group
az group create --name PacktPrivateDNSResourceGroup --location "East US"

#Create a VNet
az network vnet create \
  --name PacktPrivateDNSVNet \
  --resource-group PacktPrivateDNSResourceGroup \
  --location eastus \
  --address-prefix 10.2.0.0/16 \
  --subnet-name backendSubnet \
  --subnet-prefixes 10.2.0.0/24

#Create a private DNS zone
az network dns zone create -g PacktPrivateDNSResourceGroup \
   -n private.packtdns.com \
  --zone-type Private \
  --registration-vnets PacktPrivateDNSVNet
  
  
  
#create two virtual machines so you can test your private DNS zone:
az vm create \
 -n packtVM01 \
 --admin-username test-user \
 -g PacktPrivateDNSResourceGroup \
 -l eastus \
 --subnet backendSubnet \
 --vnet-name PacktPrivateDNSVNet \
 --image win2016datacenter

az vm create \
 -n packtVM02 \
 --admin-username test-user \
 -g PacktPrivateDNSResourceGroup \
 -l eastus \
 --subnet backendSubnet \
 --vnet-name PacktPrivateDNSVNet \
 --image win2016datacenter

#Create an additional DNS record
az network dns record-set a add-record \
  -g PacktPrivateDNSResourceGroup \
  -z private.packtdns.com \
  -n db \
  -a 10.2.0.4
  