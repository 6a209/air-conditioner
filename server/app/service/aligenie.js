const Service = require('egg').Service

const POWER_ON = 0x00;
const POWER_OFF = 0x01;

const MODE_COOL = 0x00;
const MODE_HEAT = 0x01;
const MODE_AUTO = 0x02;
const MODE_FAN = 0x03;
const MODE_DRY = 0x04;

class AligenieService extends Service {

  async command(request) {
    if (!request.payload.accessToken) return;

    const token = await this.service.user.getToken(request.payload.accessToken)
    if (token.accessTokenExpiresAt < new Date()) return;
    const uid = token.user.uid

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
        return await this.deviceCommand(deviceId, commandName, commandValue)
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
        "TurnOn", "TurnOff", "SetTemperature", "SetMode"
      ]
      return newItem
    })
    return devices
  }

  async deviceQuery() {

  } 


  async deviceCommand(deviceId, commandName, commandValue) {

    const device = await this.app.mysql.get("device", { id: deviceId })
    const key = device.productKey + "/" + device.deviceName
    
    const status = this.service.device.getStatus(key)

    if ("TurnOff" == commandName) {
      status.power = POWER_OFF 
    } else if ("TurnOn" == commandName) {
      status.power = POWER_ON
    } else if ("SetTemperature" == commandName) {
      status.power = POWER_ON
      status.temperature = commandValue
    } else if ("SetMode" == commandName) {
      status.power = POWER_ON
      status.mode = this.formatMode(commandValue)
    }
  }

  formatMode(value) {
    switch(value) {
      case "cold": return MODE_COOL
      case "heat": return MODE_HEAT
      case "dehumidification": return MODE_DRY
      case "ventilate": return MODE_FAN
    }
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