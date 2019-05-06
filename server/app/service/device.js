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
    const isBind = await this.app.mysql.get('userdevice', {uid, deviceId: item.id})
    if (isBind) {
      return {code: 500, msg: "设备已经被绑定过了"}
    }
    const result = await this.app.mysql.insert('userdevice', { uid, deviceId: item.id })
    return {code: 200, data: {uid, deviceId: item.id}}
  }

  async removeBind(uid, deviceId) {
    const result = await this.app.mysql.delete('userdevice', { uid, deviceId })
    return result
  }

  async getDetail(deviceId) {
    const result = await this.app.mysql.get('device', { 'id': deviceId })
    const productId = result.productId
    const commands = await this.app.mysql.select('command', { 'productId': productId })
    result['commands'] = commands
    return reslut
  }



  async excuteCommand({commandId, deviceId}) {
    const command = await this.app.mysql.get('command', {id: commandId})
    const device = await this.app.mysql.get('command', {id: deviceId})
    const res = {}
    res['data'] = JSON.parse(command.irdata)
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