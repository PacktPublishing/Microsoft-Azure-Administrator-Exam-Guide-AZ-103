# Create a resource group
az group create \
    --name PacktResourceGroupSLB \
    --location eastus

# Create a public IP address
az network public-ip create --resource-group PacktResourceGroupSLB --name PacktPublicIP --sku standard

# Create the load balancer
az network lb create \
    --resource-group PacktResourceGroupSLB \
    --name PacktLoadBalancer \
    --sku standard \
    --public-ip-address PacktPublicIP \
    --frontend-ip-name PacktFrontEnd \
    --backend-pool-name PacktBackEndPool

#Create the health probe
az network lb probe create \
    --resource-group PacktResourceGroupSLB \
    --lb-name PacktLoadBalancer \
    --name PacktHealthProbe \
    --protocol tcp \
    --port 80

#Create the load balancer rule
az network lb rule create \
    --resource-group PacktResourceGroupSLB \
    --lb-name PacktLoadBalancer \
    --name PacktHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name PacktFrontEnd \
    --backend-pool-name PacktBackEndPool \
    --probe-name PacktHealthProbe

#Create a virtual network
az network vnet create \
    --resource-group PacktResourceGroupSLB \
    --location eastus \
    --name PacktVnet \
    --subnet-name PacktSubnet

#Create a network security group	
az network nsg create \
    --resource-group PacktResourceGroupSLB \
    --name PacktNetworkSecurityGroup
	
#Create a network security group rule
az network nsg rule create \
    --resource-group PacktResourceGroupSLB \
    --nsg-name PacktNetworkSecurityGroup \
    --name PacktNetworkSecurityGroupRuleHTTP \
    --protocol tcp \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200

#Create NICs
for i in `seq 1 2`; do
  az network nic create \
    --resource-group PacktResourceGroupSLB \
    --name PacktNic$i \
    --vnet-name PacktVnet \
    --subnet PacktSubnet \
    --network-security-group PacktNetworkSecurityGroup \
    --lb-name PacktLoadBalancer \
    --lb-address-pools PacktBackEndPool
done

#Create an Availability set
az vm availability-set create \
   --resource-group PacktResourceGroupSLB \
   --name PacktAvailabilitySet

#Create two virtual machines

#Create an file called cloud-init.txt
sensible-editor cloud-init.txt
#Then pick an editor and copy the below text in it:

#cloud-config
package_upgrade: true
packages:
  - nginx
  - nodejs
  - npm
write_files:
  - owner: www-data:www-data
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection keep-alive;
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
  - owner: azureuser:azureuser
  - path: /home/azureuser/myapp/index.js
    content: |
      var express = require('express')
      var app = express()
      var os = require('os');
      app.get('/', function (req, res) {
        res.send('Hello World from host ' + os.hostname() + '!')
      })
      app.listen(3000, function () {
        console.log('Hello world app listening on port 3000!')
      })
runcmd:
  - service nginx restart
  - cd "/home/azureuser/myapp"
  - npm init
  - npm install express -y
  - nodejs index.js

#Create two virtual machines  
for i in `seq 1 2`; do
 az vm create \
   --resource-group PacktResourceGroupSLB \
   --name myVM$i \
   --availability-set PacktAvailabilitySet \
   --nics PacktNic$i \
   --image UbuntuLTS \
   --generate-ssh-keys \
   --custom-data cloud-init.txt \
   --no-wait
done

#Test the load balancer
#Obtain public IP address
az network public-ip show \
    --resource-group PacktResourceGroupSLB \
    --name PacktPublicIP \
    --query [ipAddress] \
    --output tsv