param name string
param keyVaultName string
param keyVaultSecretName string

var containerName = 'logic-app-demo-files'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/${containerName}'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVaultName}/${keyVaultSecretName}'
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'text/plain'
    value: 'DefaultEndpointsProtocol=https;AccountName=${name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
}

output name string = storageAccount.name
