const Service = require('egg').Service

class AligenieService extends Service {

  async command(request) {
    if (!request.payload.accessToken) return;

    const uid = await this.service.user.getUidByToken(request.payload.accessToken)

    if (request.header) {
      if ("DiscoveryDevices" == request.header.name) {
        return await this.deviceDiscovery(uid)
      } else if ("Query" == request.header.name) {
        return await this.deviceQuery(uid);
      } else {
        // command
        const deviceId = request.payload.deviceId
        const commandName = request.header.name 
        const commandValue = request.payload.value
        this.deviceCommand(deviceId, commandName, commandValue)
      }
    }
  }

  async deviceDiscovery(uid) {
    let devices = await this.service.device.getUserDevice(uid)  
    
    devices = devices.map((item) => {
      const newItem = {}
      newItem["deviceId"] = item.id
      newItem["deviceName"] = item.name
      newItem["deviceType"] = "aircondition"
      newItem["icon"] = ""
      newItem["properties"] = this.generateProperties()
      newItem["actions"] = [
        "TurnOn", "TurnOff", "SetTemperature"
      ]
      return newItem
    })
    return devices
  }

  async deviceQuery() {

  } 

  async deviceCommand(deviceId, commandName, commandValue) {

  }

  generateProperties() {
    const properties = []
    properties.push({
      "name": "powerstate",
      "value": "on"
    })
    properties.push({
      "name": "temperature",
      "value": "20"
    })
    return properties;
  }
}

module.exports = AligenieService