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
    const device = await this.app.mysql.get('device', { productKey: pk, deviceName: dn })
    if (device) {
      const uid = await this.app.mysql.get('userdevice', { 'deviceId': device.id })
      const user = await this.app.mysql.get('user', { id: uid.uid })
      return user.topic
    }
  }

  async hasDevice(uid, deviceId) {
    console.log("hasDevice")
    console.log(uid)
    console.log(deviceId)
    const result = await this.app.mysql.get('userdevice', { uid, deviceId })
    return result
  }

  async createBind(uid, pk, dn) {
    console.log(pk)
    console.log(dn)
    const item = await this.app.mysql.get('device', { productKey: pk, deviceName: dn })
    const isBind = await this.app.mysql.get('userdevice', { uid, deviceId: item.id })
    if (isBind) {
      return { code: 500, msg: "设备已经被绑定过了" }
    }
    const result = await this.app.mysql.insert('userdevice', { uid, deviceId: item.id })
    return { code: 200, data: { uid, deviceId: item.id } }
  }

  async removeBind(uid, deviceId) {
    const result = await this.app.mysql.delete('userdevice', { uid, deviceId })
    return result
  }

  async getDetail(deviceId) {
    console.log('--->> deviceId' + deviceId)
    let result = await this.app.mysql.get('device', { 'id': deviceId })
    console.log(result)
    const productId = result.productId
    const commands = await this.app.mysql.select('command', { 'productId': productId })
    result['commands'] = commands
    // get device status 
    const key = result.productKey + "/" + result.deviceName
    let status = await this.getStatus(key)
    result = Object.assign(result, status)
    return result
  }

  async excuteCommand({ commandId, deviceId }) {

    console.log(commandId)
    const command = await this.app.mysql.get('command', { id: commandId })
    const device = await this.app.mysql.get('device', { id: deviceId })
    const res = {}
    console.log(command)
    try {
      res['data'] = JSON.parse(command.irdata)
    } catch (e) {
      return { code: 500, msg: "command irdata json parse error" }
    } 
    res['name'] = command.name
    res['value'] = command.value
    res['deviceId'] = deviceId
    const message = JSON.stringify(res)
    const key = device.productKey + "/" + device.deviceName
    let status = await this.getStatus(key) || "{}"

    status = JSON.parse(status)
    console.log("---status-----")
    console.log(status)

    if (status.online !== 1) {
      return { code: 500, msg: "device not online" }
    }

    if (!this.app.client.connected) {
      console.log("mqtt server disconnect")
      return { code: 500, msg: "mqtt server disconnect" }
    }
    try {
      const commandTopic = "device/sendCommand/" + device.productKey + "/" + device.deviceName

      console.log("--- topic -----")
      console.log(commandTopic)
      console.log(message)
      console.log(message.length)
      await this.app.client.publish(commandTopic, message)
    } catch (e) {
      return {code: 500, msg: "device mqtt disconnect"}
    }
    // status = this.name2Status(command.name);
    // this.updateStatus({key, status})
    return {code: 200, msg: 'ok'}
  }

  async updateStatus({ key, status }) {
    let oldStatus = await this.app.redis.get(key)
    try {
      oldStatus = JSON.parse(oldStatus) 
    } catch(e) {
      oldStatus = {}
    }
    status = Object.assign(oldStatus, status)
    status = JSON.stringify(status)
    return await this.app.redis.set(key, status)
  }

  async getStatus(key) {
    return await this.app.redis.get(key)
  }

   
}

module.exports = DeviceService