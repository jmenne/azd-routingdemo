targetScope = 'resourceGroup'

// CONTRIBUTOR: Add your Azure resources here - uncomment the example below or add your own.
// See .github/instructions/bicep.instructions.md for patterns.

param environmentName string
param location string = resourceGroup().location
param tags object = {}

// Load abbreviations for resource naming
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// EXAMPLE: Storage Account (replace with your resources)
// Uncomment and customize, or delete and add your own resources
//
// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//   name: '${abbrs.storageStorageAccounts}${resourceToken}'
//   location: location
//   tags: tags
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     minimumTlsVersion: 'TLS1_2'
//     allowBlobPublicAccess: false
//   }
// }

// CONTRIBUTOR: Add outputs for resources that need to be referenced
// by applications or displayed after deployment. Use UPPER_SNAKE_CASE.
// 
// output STORAGE_ACCOUNT_NAME string = storageAccount.name
// output STORAGE_ACCOUNT_ID string = storageAccount.id 
