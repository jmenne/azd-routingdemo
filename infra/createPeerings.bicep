// Create VNet Peerings between Central-VNet and the production VNets

@description('Names of the VNets to be peered')
param networkNames array = [
  'production-VNet1'
  'production-VNet2'
]

@description('Sets the remote VNet Resource group')
param RemoteResourceGroupName string = resourceGroup().name

// Create VNet Peerings from Central-VNet to the production VNets
resource LocalVirtualNetworkName_peering_to_remote_vnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = [
  for netName in networkNames: {
    name: 'Central-VNet/to_${netName}'
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
      remoteVirtualNetwork: {
        id: resourceId(RemoteResourceGroupName, 'Microsoft.Network/virtualNetworks', netName)
      }
    }
  }
]

// Create VNet Peerings from the production VNets to Central-VNet
resource RemoteVirtualNetworkName_peering_to_local_vnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = [
  for netName in networkNames: {
    name: '${netName}/to_Central-VNet'
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
      remoteVirtualNetwork: {
        id: resourceId(RemoteResourceGroupName, 'Microsoft.Network/virtualNetworks', 'Central-VNet')
      }
    }
  }
]
