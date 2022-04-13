param name string

@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param skuSize string = 'WS1'

resource appServicePlanWorkflow 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: name
  location: resourceGroup().location
  kind: 'windows'
  sku: {
    name: skuSize
    tier: 'WorkflowStandard'
    size: skuSize
  }
}

output serverFarmId string = appServicePlanWorkflow.id
