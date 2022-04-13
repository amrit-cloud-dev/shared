param name string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: resourceGroup().location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    accessPolicies: []
    publicNetworkAccess: 'ENABLED'
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

output name string = keyVault.name
