param blobConnectionName string
param storageAccountName string

// Ensure that every connection created below is added to this Array. LogicApp module will loop over this array to grant access.
var connectionList = [
  blobConnectionName
]

var storageAccountId = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)

resource logicAppBlobConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: blobConnectionName
  location: resourceGroup().location
  kind: 'V2'
  properties: {
    displayName: blobConnectionName
    parameterValues: {
      accountName: storageAccountName
      accessKey: listKeys(storageAccountId, '2021-04-01').keys[0].value
    }
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${resourceGroup().location}/managedApis/azureblob'
    }
  }
}

output connectionList array = connectionList
output blobConnectionRuntimeUrl string = logicAppBlobConnection.properties.connectionRuntimeUrl
