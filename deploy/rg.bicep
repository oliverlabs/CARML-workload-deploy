targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Required. The name of the resource group to deploy')
param resourceGroupName string = 'carml-rg'

@description('Optional. The location to deploy into')
param location string = deployment().location

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

// ======= //
// Outputs //
// ======= //

@description('The resource ID of the deployed resource group')
output resourceGroupResourceId string = rg.outputs.resourceId
