const Service = require('egg').Service


class DeviceService extends Service {


  async getUserDevice(uid) {
    let userDevice = await this.app.mysql.select('userdevice', { id: uid })
    console.log(userDevice)
    const deviceIds = []
    for (const item of userDevice) {
      deviceIds.push(item.deviceId)
    }
    userDevice = await this.app.mysql.select('device', { id: deviceIds })
    return userDevice
  }

  async updateDeviceName(deviceId, name) {
    const row = {
      id: deviceId,
      name: name
    }
    await this.app.mysql.update('device', row)
  }

  async getTopicByDevice(pk, dn) {
    const device = await this.app.mysql.get('device', {productKey: pk, deviceName: dn})
    if (device) {
      const uid = await this.app.mysql.get('userdevice', {'deviceId': device.id}) 
      const user = await this.app.mysql.get('user', {id: uid.uid})
      return user.topic
    }  
  }

  async hasDevice(uid, deviceId) {
    const result = await this.app.mysql.get('userdevice', { uid, deviceId })
    return result
  }

  async createBind(uid, pk, dn) {
    console.log(pk)
    console.log(dn)
    const item = await this.app.mysql.get('device', { productKey: pk, deviceName: dn })
    console.log(item)
    const result = await this.app.mysql.insert('userdevice', { uid, deviceId: item.id })
    return {uid, deviceId: item.id} 
  }

  async removeBind(uid, deviceId) {
    const result = await this.app.mysql.delete('userdevice', { uid, deviceId })
    return result
  }

  async getDetail(deviceId) {
    const result = await this.app.mysql.get('device', { 'id': deviceId })
    const productId = result[0].productId
    const commands = await this.app.mysql.select('command', { 'productId': productId })
    result['commands'] = commands
    return reslut
  }

  async createCommands({ productId, commands }) {
    // const conn = await app.mysql.beginTransaction(); 
    const rows = []
    try {
      for (let command of commands) {
        let item = {}
        item['name'] = command.name 
        item['irdata'] = command.irdata
        item['productId'] = productId
        rows.push(item)
      }
      await this.app.mysql.insert('command', rows)
    } catch (err) {
      console.log(err)
    }
  }

  async updateCommands({commands}) {
    try {
      await this.app.mysql.updateRows('command', commands)
    } catch(err) {
      console.log(err)
    }
  }

  async excuteCommand({commandId, deviceId}) {
    const command = await this.app.mysql.get('command', {id: commandId})
    const device = await this.app.mysql.get('command', {id: deviceId})
    const res = {}
    res['data'] = command.irdata
    const message = JSON.stringify(res) 
    if (this.app.client.connected()) {
      this.app.client.publish(
        "device/sendCommand/" + device.productKey + "/" + device.deviceName, message)
    } else {
      console.log("client disconnect")
    }
  }
}

module.exports = DeviceService