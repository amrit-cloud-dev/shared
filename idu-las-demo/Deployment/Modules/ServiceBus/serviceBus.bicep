param name string
param keyVaultName string
param keyVaultSecretName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  name: '${serviceBus.name}/sbq-logic-app-demo'
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVaultName}/${keyVaultSecretName}'
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'text/plain'
    value: listkeys(resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', serviceBus.name, 'RootManageSharedAccessKey'), '2021-01-01-preview').primaryConnectionString
  }
}
