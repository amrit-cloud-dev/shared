param name string
param serverFarmId string
param keyVaultName string
param storageAccountSecretName string
param appInsightsSecretName string
param serviceBusConnectionStringSecretName string
param logicAppConnectionList array
param blobConnectionProperties object

// create LogicApp
resource logicApp 'Microsoft.Web/sites@2021-01-15' = {
  name: name
  location: resourceGroup().location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarmId
    clientAffinityEnabled: false
  }
}

// Give LogicApp access to KeyVault
resource logicAppKeyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: logicApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Apply LogicApp AppSettings
resource logicAppAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${logicApp.name}/appsettings'
  properties: {
    APP_KIND: 'workflowApp'
    AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
    AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_NODE_DEFAULT_VERSION: '~12'

    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${storageAccountSecretName})'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${storageAccountSecretName})'
    WEBSITE_CONTENTSHARE: '${toLower(logicApp.name)}-${substring(uniqueString(resourceGroup().name), 0, 4)}'
    APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${appInsightsSecretName})'
    
    WORKFLOWS_SUBSCRIPTION_ID: subscription().subscriptionId
    WORKFLOWS_RESOURCE_GROUP_NAME: resourceGroup().name
    WORKFLOWS_LOCATION_NAME: resourceGroup().location
    STORAGE_ACCOUNT_NAME: blobConnectionProperties.storageAccountName
    BLOB_CONNECTION_NAME: blobConnectionProperties.blobConnectionName
    BLOB_CONNECTION_URL: blobConnectionProperties.blobConnectionUrl
    SERVICE_BUS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${serviceBusConnectionStringSecretName})'
  }
  dependsOn: [
    logicAppKeyVaultAccess
  ]
}

// Give LogicApp access to connection
resource logicAppConnectionAccess 'Microsoft.Web/connections/accessPolicies@2016-06-01' = [for connection in logicAppConnectionList: {
  name: '${connection}/${logicApp.name}'
  location: resourceGroup().location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: logicApp.identity.principalId
      }
    }
  }
}]


