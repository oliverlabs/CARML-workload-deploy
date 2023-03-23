targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy into')
param location string = 'westeurope'

module vnet 'br/modules:microsoft.network.virtualnetworks:0.1.1945' = {
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
}
