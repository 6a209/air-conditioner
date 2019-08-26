const Service = require('egg').Service
const fs = require("fs");
const addon = require('../../build/Release/addon.node');
// const addon = require('../../../build/Release/addon.node');


class DeviceService extends Service {


  async getUserDevice(uid) {
    let userDevice = await this.app.mysql.select('userdevice', { where: { uid: uid } })
    console.log(userDevice)
    const deviceIds = []
    for (const item of userDevice) {
      deviceIds.push(item.deviceId)
    }
    userDevice = await this.app.mysql.select('device', { where: { id: deviceIds } })
    return userDevice
  }

  async getDeviceByPkDn(pk, dn) {
    const device = await this.app.mysql.get('device', { productKey: pk, deviceName: dn })
    return device
  }

  async createDevice(deviceName, productKey, secreKey) {
    const result = await this.app.mysql.insert('device', { deviceName, productKey, secreKey })
    return result;
  }

  async updateDeviceName(deviceId, name) {
    console.log("updateDeviceName")
    console.log(deviceId, name)
    const row = {
      id: deviceId,
      name: name
    }
    await this.app.mysql.update('device', row)
  }

  async getTopicByDevice(pk, dn) {
    const device = await this.app.mysql.get('device', { productKey: pk, deviceName: dn })
    if (!device) {
      return null
    }
    const bindInfo = await this.app.mysql.get('userdevice', { 'deviceId': device.id })
    if (!bindInfo) {
      return null
    }
    const user = await this.app.mysql.get('user', { id: bindInfo.uid })
    return user.topic

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

  async bindBrandDevice({ uid, pk, dn, name, brand, brandMode }) {
    const device = await this.getDeviceByPkDn(pk, dn)
    const deviceId = device.id
    const isBind = await this.app.mysql.get('userdevice', { uid, deviceId })
    if (isBind) {
      return { code: 500, msg: "设备已经被绑定过了" }
    }

    let result = await this.service.product.createProduct(uid, { brand, brand_mode: brandMode, type: 0 })
    await this.app.mysql.insert("userdevice", { uid, deviceId })
    const row = {
      id: deviceId,
      name: name,
      productId: result.pid
    }
    await this.app.mysql.update('device', row)
    return { code: 200, msg: "" }
  }

  async unbindByDevice(pk, dn) {
    try {
      await this.app.mysql.beginTransactionScope(async conn => {
        const device = await conn.get('device', {productKey: pk, deviceName: dn})
        await conn.delete('userdevice', {deviceId: device.id})
        device['productId'] = null
        device['name'] = null
        await conn.update('device', device)
      }, this.ctx)
    } catch(e) {
    }
  } 

  async unbind(uid, deviceId) {
    try {
      await this.app.mysql.beginTransactionScope(async conn => {
        await conn.delete('userdevice', { uid, deviceId })
        const device = await conn.get("device", { 'id': deviceId })
        device['productId'] = null
        device['name'] = null
        await conn.update('device', device)
      }, this.ctx)
    } catch (e) {
      console.log(e)
      return {code: 500, msg: "db error"}
    }
    return result
  }

  async getDetail(deviceId) {
    console.log('--->> deviceId' + deviceId)
    let result = await this.app.mysql.get('device', { 'id': deviceId })
    console.log("get detail")
    console.log(result)
    const key = result.productKey + "/" + result.deviceName
    let status = await this.getStatus(key)
    console.log(status)
    status = JSON.parse(status)

    console.log("status -->>>")
    console.log(status)
    result = Object.assign(result, status)
    console.log(result)
    return result
  }

  async executeCommand(commandInfo) {
    const device = await this.app.mysql.get("device", { id: commandInfo.deviceId })
    let deviceId = device.id
    // let brandMode = commandInfo.brandMode
    if (device.productId) {
      const product = await this.service.product.getProduct(device.productId)
      commandInfo.brandMode = product.brand_mode
      console.log(product)
    }
    let result = {}
    if (commandInfo.brandMode) {
      result = await this.executeBrandCommand(commandInfo, deviceId)
    } else {
      result = await this.executeCustomCommand(commandInfo, deviceId)
    }
    return result
  }

  async executeBrandCommand(commandInfo, deviceId) {
    console.log(commandInfo)
    const data = fs.readFileSync("./data/irda_" + commandInfo.brandMode + ".bin")
    let irdata = addon.decode(data, commandInfo.power, commandInfo.mode, commandInfo.temperature)
    console.log("--->>>> deviceId" + deviceId)
    return this._executeCommand({ commandInfo, deviceId, irdata })
  }

  async executeCustomCommand(commandInfo, deviceId) {

  }

  async _executeCommand({ commandInfo, deviceId, irdata }) {

    const device = await this.app.mysql.get('device', { id: deviceId })
    const key = device.productKey + "/" + device.deviceName
    let status = await this.getStatus(key) || "{}"
    status = JSON.parse(status)
    console.log("status")
    console.log(status)
    console.log("--------------------------------")
    if (status.online !== 1) {
      return { code: 500, msg: "device not online" }
    }

    if (!this.app.client.connected) {
      console.log("mqtt server disconnect")
      return { code: 500, msg: "mqtt server disconnect" }
    }

    const size = irdata.length
    irdata = JSON.stringify(irdata)

    const info = {}
    info['power'] = commandInfo.power
    info['mode'] = commandInfo.mode
    info['temperature'] = commandInfo.temperature
    info['deviceId'] = deviceId
    console.log("info ->>>>> ")
    console.log(info)
    const message = JSON.stringify(info) + "&" + irdata + "&" + size

    try {
      const commandTopic = "device/sendCommand/" + device.productKey + "/" + device.deviceName
      await this.app.client.publish(commandTopic, message)
    } catch (e) {
      return { code: 500, msg: "device mqtt disconnect" }
    }
    return { code: 200, msg: 'ok' }
  }

  async updateStatus({ key, status }) {
    console.log("udpate _____ ***** _>>>> status")
    console.log("key:" + key)
    console.log("status: ")
    if (!status) {
      status = {}
    }
    let oldStatus = await this.app.redis.get(key)
    try {
      oldStatus = JSON.parse(oldStatus)
    } catch (e) {
    }
    if (!oldStatus) {
      oldStatus = {}
    }
    status = Object.assign(oldStatus, status)
    status = JSON.stringify(status)

    console.log(status)
    console.log("==========****========")

    return await this.app.redis.set(key, status)
  }

  async getStatus(key) {
    return await this.app.redis.get(key)
  }


}

module.exports = DeviceService