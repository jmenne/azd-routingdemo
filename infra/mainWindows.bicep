@description('The location of all resources')
param location string = resourceGroup().location

// Parameters for the VNets
@description('Names of the Vnets to be created')
param networkNames array = [
  'Central-VNet'
  'production-VNet1'
  'production-VNet2'
]

param addressPrefixes array = [
  '10.0.0.0/16'
  '10.1.0.0/16'
  '10.2.0.0/16'
]

// Parameters for the VMs

@description('Admin username for the VMs')
param adminUsername string = 'student'

@description('Admin password for the VMs')
@secure()
param adminPassword string

@description('OSVersion for the Windows VMs')
@allowed([
  '2019-Datacenter'
  '2022-Datacenter'
  '2025-Datacenter'
  '2019-Datacenter-gensecond'
  '2022-Datacenter-g2'
  '2025-Datacenter-g2'
])
param windowsOSVersion string = '2022-Datacenter'

@description('Size of the VMs')
param vmSize string = 'Standard_D2s_v5'

@description('Names of the VMs to be created')
param vmNames array = [
  'NVA-VM'
  'Production-VM1'
  'Production-VM2'
]

// Virtual Networks
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = [
  for (name, i) in networkNames: {
    name: name
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [
          addressPrefixes[i]
        ]
      }
      subnets: name == 'Central-VNet'
        ? [
            {
              name: 'Subnet1'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '1.0/24')
              }
            }
            {
              name: 'Subnet2'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '2.0/24')
              }
            }
            {
              name: 'AzureBastionSubnet'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '250.0/26')
              }
            }
            {
              name: 'GatewaySubnet'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '251.0/26')
              }
            }
          ]
        : [
            {
              name: 'Subnet1'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '1.0/24')
              }
            }
            {
              name: 'Subnet2'
              properties: {
                addressPrefix: replace(addressPrefixes[i], '0.0/16', '2.0/24')
              }
            }
          ]
    }
  }
]

//Network Security Groups
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = [
  for name in vmNames: {
    name: 'NSG-${name}'
    location: location
    properties: {
      securityRules: [
        {
          name: 'Allow-RDP'
          properties: {
            priority: 300
            protocol: 'Tcp'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
        {
          name: 'Allow-http'
          properties: {
            priority: 310
            protocol: 'Tcp'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '80'
          }
        }
      ]
    }
  }
]

// NICs for the VMs
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = [
  for (vmName, i) in vmNames: {
    name: '${vmName}-nic'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: vnet[i].properties.subnets[0].id
            }
            privateIPAllocationMethod: 'Dynamic'
          }
        }
      ]
      networkSecurityGroup: {
        id: nsg[i].id
      }
    }
    dependsOn: [
      vnet
      nsg
    ]
  }
]

// Virtual Machines in Subnet1 of each VNet
resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = [
  for (vmName, i) in vmNames: {
    name: vmName
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: vmName
        adminUsername: adminUsername
        adminPassword: adminPassword
        windowsConfiguration: {
          provisionVMAgent: true
          enableAutomaticUpdates: true
        }
      }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: windowsOSVersion
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: nic[i].id
          }
        ]
      }
    }
    dependsOn: [
      nic
    ]
  }
]

// Custom Script Extension for VMs
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [
  for (vmName, i) in vmNames: {
    name: '${vmName}/CustomScriptExtension'
    location: location
    dependsOn: [
      vm[i]
    ]
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
      }
    }
  }
]
