@description('Project Prefix')
@minLength(3)
param prefix string = 'anbossar'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies the IotHub SKU.')
param skuName string = 'F1'

@description('Specifies the number of provisioned IoT Hub units. Restricted to 1 unit for the F1 SKU. Can be set up to maximum number allowed for subscription.')
@minValue(1)
@maxValue(1)
param capacityUnits int = 1

var iotHubName = '${prefix}-iot-hub'
var consumerGroupName_var = '${iotHubName}/events/cg1'

resource iotHubName_resource 'Microsoft.Devices/IotHubs@2021-03-31' = {
  name: iotHubName
  location: location
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 2
      }
    }
    cloudToDevice: {
      defaultTtlAsIso8601: 'PT1H'
      maxDeliveryCount: 10
      feedback: {
        ttlAsIso8601: 'PT1H'
        lockDurationAsIso8601: 'PT60S'
        maxDeliveryCount: 10
      }
    }
    messagingEndpoints: {
      fileNotifications: {
        ttlAsIso8601: 'PT1H'
        lockDurationAsIso8601: 'PT1M'
        maxDeliveryCount: 10
      }
    }
  }
  sku: {
    name: skuName
    capacity: capacityUnits
  }
}

resource consumerGroupName 'Microsoft.Devices/iotHubs/eventhubEndpoints/ConsumerGroups@2021-03-31' = {
  name: consumerGroupName_var
  properties: {
    name: 'cg1'
  }
  dependsOn: [
    iotHubName_resource
  ]
}

var adtName = '${prefix}-adt'

resource symbolicname 'Microsoft.DigitalTwins/digitalTwinsInstances@2020-12-01' = {
  name: adtName
  location: location
  tags: {
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}
