param name string
param keyVaultName string
param keyVaultSecretName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVaultName}/${keyVaultSecretName}'
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'text/plain'
    value: appInsights.properties.InstrumentationKey
  }
}
