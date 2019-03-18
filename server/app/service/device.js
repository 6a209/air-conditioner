const Service = require('egg').Service


class DeviceService extends Service {


    async getUserDevice(uid) {
      let userDevice = await this.app.mysql.get('userdevice', {id: uid})
      console.log(userDevice)
      const deviceIds = []
      for (const item of userDevice) {
        deviceIds.push(item.deviceId)
      }
      userDevice = await this.app.mysql.get('device', {id: deviceIds}) 
      return userDevice
    }

    async updateDeviceName(deviceId, name) {
      const row = {
        id: deviceId,
        name: name
      }
      await this.app.mysql.update('device', row)
    }

    async hasDevice(uid, deviceId) {
      const result = await this.app.mysql.get('userdevice', {uid, deviceId})
      return result
    }

    async createBind(uid, deviceId) {
      const result = await this.app.mysql.insert('userdevice', {uid, deviceId})
      return result 
    }

    async removeBind(uid, deviceId) {
      const result = await this.app.mysql.delete('userdevice', {uid, deviceId})
      return result
    }

    async getDetail(deviceId) {
      const result = await this.app.mysql.get('device', {'id': deviceId})
      const productId = result[0].productId
      const commands = await this.app.mysql.get('command', {'productId': productId})
      result['commands'] = commands
      return reslut
    }
}