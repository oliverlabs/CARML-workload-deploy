targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Required. The name of the resource group to deploy')
param resourceGroupName string = 'carml-rg'

@description('Optional. The location to deploy into')
param location string = deployment().location

@description('Required. The name of the storage account to deploy')
param storageAccountName string

// =========== //
// Deployments //
// =========== //

module rg 'br/modules:microsoft.resources.resourcegroups:0.1.1932' = {
  name: 'workload-rg'
  params: {
    name: resourceGroupName
    location: location
  }
}

module vnet 'br/modules:microsoft.network.virtualnetworks:0.1.1945' = {
  scope: resourceGroup(resourceGroupName)
  name: 'vnet-deploy-${uniqueString(deployment().name, location)}'
  params: {
    addressPrefixes: [
      '10.231.0.0/16'
    ]
    name: 'carml-vnet'
    subnets: [
      {
        addressPrefix: '10.231.0.0/24'
        name: 'carml-subnet-01'
      }
      {
        addressPrefix: '10.231.1.0/24'
        name: 'carml-subnet-02'
      }
    ]
  }
  dependsOn: [
    rg
  ]
}

// module pdns 'br/modules:microsoft.network.privatednszones:0.5' = {
//   scope: resourceGroup(resourceGroupName)
//   name: 'workload-pdns'
//   params: {
//     name: 'carml.com'
//     virtualNetworkLinks: [
//       {
//         registrationEnabled: true
//         virtualNetworkResourceId: vnet.outputs.resourceId
//       }
//     ]
//   }
//   dependsOn: [
//     rg, vnet
//   ]
// }

module pdns 'br/modules:microsoft.network.privatednszones:0.5' = {
  scope: resourceGroup(resourceGroupName)
  name: 'workload-pdns'
  params: {
    name: 'privatelink.blob.core.windows.net'
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: vnet.outputs.resourceId
      }
    ]
  }
  dependsOn: [
    rg, vnet
  ]
}

module sa 'br/modules:microsoft.storage.storageaccounts:0.1.1932' = {
  scope: resourceGroup(resourceGroupName)
  name: 'workload-sa'
  params: {
    name: storageAccountName
    allowBlobPublicAccess: false
    blobServices: {
      containers: [
        {
          name: 'carml-container'
          publicAccess: 'None'
        }
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDNSResourceIds: [
            pdns.outputs.resourceId
          ]
        }
        service: 'blob'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
  }
  dependsOn: [
    rg, vnet, pdns
  ]
}

// ======= //
// Outputs //
// ======= //

@description('The resource ID of the deployed resource group')
output resourceGroupResourceId string = rg.outputs.resourceId

@description('The resource ID of the deployed storage account')
output storageAccountResourceId string = sa.outputs.resourceId

@description('The resource ID of the deployed virtual network')
output virtualNetworkResourceId string = vnet.outputs.resourceId

@description('The resource ID of the deployed subnet')
output subnetResourceIds array = vnet.outputs.subnetResourceIds

@description('The resource ID of the deployed private DNS zone')
output privateDnsZoneResourceId string = pdns.outputs.resourceId
