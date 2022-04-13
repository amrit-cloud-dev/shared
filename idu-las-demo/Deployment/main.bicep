@allowed([
  'test'
  'prod'
])
param environment string = 'test'

param locationCode string = 'ase'
param component string = 'idu'
param releaseId string = 'manual-${utcNow('ddMMyyyyHHmm')}'

var resourceNameSuffix = '${locationCode}-${environment}'
var uniqueNamePart = substring(uniqueString(resourceGroup().id, subscription().id), 0, 6)
var baseName = '-${component}-${uniqueNamePart}-${resourceNameSuffix}'
var baseNameShort = '-${component}-${uniqueNamePart}-${resourceNameSuffix}'

var connectionNamePrefix = 'con-${component}-'
var connectionNameSuffix = '-${uniqueNamePart}-${resourceNameSuffix}'

var resourceNames = {
  appServicePlan: 'aspw${baseName}'
  logicApp: 'la${baseName}'
  keyVault: 'kv${baseNameShort}'
  storageAccount: 'sa${replace(baseNameShort, '-', '0')}'
  appInsights: 'appi${baseName}'
  serviceBus: 'sb${baseName}'
  keyVaultSecretName: {
    storageAccountConnectionString: 'sa-connection-string'
    appInsightInstrumentionKey: 'appi-instrumention-key'
    serviceBusConnectionString: 'sb-connection-string'
  }
  logicAppConnections: {
    azureBlobConnection: '${connectionNamePrefix}azure-blob${connectionNameSuffix}'
  }
}

module keyVault 'Modules/KeyVault/keyVault.bicep' = {
  name: 'kv-${releaseId}'
  params: {
    name: resourceNames.keyVault
  }
}

module storageAccount 'Modules/StorageAccount/storageAccount.bicep' = {
  name: 'sa-${releaseId}'
  params: {
    name: resourceNames.storageAccount
    keyVaultName: keyVault.outputs.name
    keyVaultSecretName: resourceNames.keyVaultSecretName.storageAccountConnectionString
  }
}

module appInsights 'Modules/AppInsights/appInsights.bicep' = {
  name: 'appi-${releaseId}'
  params: {
    name: resourceNames.appInsights
    keyVaultName: keyVault.outputs.name
    keyVaultSecretName: resourceNames.keyVaultSecretName.appInsightInstrumentionKey
  }
} 

module serviceBus 'Modules/ServiceBus/serviceBus.bicep' = {
  name: 'sb-${releaseId}'
  params: {
    name: resourceNames.serviceBus
    keyVaultName: keyVault.outputs.name
    keyVaultSecretName: resourceNames.keyVaultSecretName.serviceBusConnectionString
  }
}

module laConnections 'Modules/LogicApp/connection.bicep' = {
  name: 'la-con-${releaseId}'
  params: {
    blobConnectionName: resourceNames.logicAppConnections.azureBlobConnection
    storageAccountName: storageAccount.outputs.name
  }
}

module appServicePlan 'Modules/LogicApp/appServicePlanWorkflow.bicep' = {
  name: 'asp-${releaseId}'
  params: {
    name: resourceNames.appServicePlan
  }
}

module laApp 'Modules/LogicApp/logicApp.bicep' = {
  name: 'la-${releaseId}'
  params: {
    name: resourceNames.logicApp
    serverFarmId: appServicePlan.outputs.serverFarmId
    storageAccountSecretName: resourceNames.keyVaultSecretName.storageAccountConnectionString
    appInsightsSecretName: resourceNames.keyVaultSecretName.appInsightInstrumentionKey
    serviceBusConnectionStringSecretName: resourceNames.keyVaultSecretName.serviceBusConnectionString
    keyVaultName: keyVault.outputs.name
    logicAppConnectionList: laConnections.outputs.connectionList
    blobConnectionProperties: {
      blobConnectionUrl: laConnections.outputs.blobConnectionRuntimeUrl
      blobConnectionName: resourceNames.logicAppConnections.azureBlobConnection
      storageAccountName: resourceNames.storageAccount
    }
  }
}

output LogicAppName string = resourceNames.logicApp
