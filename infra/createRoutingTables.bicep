// Create Route-Table from VNet1 to VNet2 and vice versa by using the NVA as the next hop

@description('The location for the route-tables')
param location string = resourceGroup().location

@description('Name of the first route-table')
param rtName1 string = 'VNet1-to-VNet2-RT'

@description('Name of the second route-table')
param rtName2 string = 'VNet2-to-VNet1-RT'

var VNet1AddressPrefix = '10.1.0.0/16'
var VNet1Subet1AddressPrefix = replace(VNet1AddressPrefix, '0.0/16', '1.0/24')
var VNet2AddressPrefix = '10.2.0.0/16'
var VNet2Subet1AddressPrefix = replace(VNet2AddressPrefix, '0.0/16', '1.0/24')
var NVAIPAddress = '10.0.1.4'

// First Route-Table from VNet1 to VNet2
resource routeTable1 'Microsoft.Network/routeTables@2021-05-01' = {
  name: rtName1
  location: location
  properties: {
    routes: [
      {
        name: 'Route-to-VNet2-via-NVA'
        properties: {
          addressPrefix: VNet2AddressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: NVAIPAddress
        }
      }
    ]
  }
}

// Assigning route table to subnet1 of VNet1
resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'production-VNet1'
}

resource routeTable1Association 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet1
  name: 'Subnet1'
  properties: {
    addressPrefix: VNet1Subet1AddressPrefix
    routeTable: {
      id: routeTable1.id
    }
  }
}

// Second Route-Table from VNet2 to VNet1
resource routeTable2 'Microsoft.Network/routeTables@2021-05-01' = {
  name: rtName2
  location: location
  properties: {
    routes: [
      {
        name: 'Route-to-VNet1-via-NVA'
        properties: {
          addressPrefix: VNet1AddressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: NVAIPAddress
        }
      }
    ]
  }
}

// Assigning route table to subnet1 of VNet2
resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'production-VNet2'
}

resource routeTable2Association 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet2
  name: 'Subnet1'
  properties: {
    addressPrefix: VNet2Subet1AddressPrefix
    routeTable: {
      id: routeTable2.id
    }
  }
}
