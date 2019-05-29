#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create custom role in Azure
New-AzRoleDefinition -InputFile "C:\CustomRoles\PacktCustomRole.json"