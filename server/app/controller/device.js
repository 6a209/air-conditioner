'use strict';

const Controller = require('egg').Controller;

class DeviceController extends Controller {


  async bind() {
    const { app, ctx } = this
    const uid = this.getUid() 
    // const deviceId = ctx.request.body.deviceId
    const pk = ctx.request.body.pk
    const dn = ctx.request.body.dn
    const result = await this.service.device.createBind(uid, pk, dn)
    if (result) {
      ctx.body = ctx.helper.successRes(200, result)
    } else {
      ctx.body = ctx.helper.failRes(500, 'dberror')
    } 
  }

  async unbind() {
      const { app, ctx } = this
      const uid = this.getUid()
      const deviceId = ctx.request.body.deviceId
      const result = await this.service.device.removeBind(uid, deviceId) 
      if (result) {
        ctx.body = ctx.helper.successRes(200)
      } else {
        ctx.body = ctx.helper.failRes(500, 'dberror')
      }
  }

  async setDeviceAlias() {
      const { app, ctx } = this
      const uid = this.getUid()
      const deviceId = ctx.request.body.deviceId
      const name = ctx.request.body.name
      const result = await this.service.device.hasDevice(uid, deviceId)
      if (!result) {
        ctx.body = ctx.helper.failRes(403, '你没有这个设备权限')
        return
      }
      this.service.device.updateDeviceName(deviceId, name)
      ctx.body = ctx.helper.successRes(200)
  }

  /**
   * 首页设备列表
   */
  async list() {
    const { app, ctx } = this
    const uid = this.getUid()
    const result = await this.service.device.getUserDevice(uid) 
    const formatResult = [] 
    for (const item of result) {
      const formatItem = {}
      formatItem['productId'] = item.productId 
      formatItem['icon'] = item.icon
      formatItem['name'] = item.name
      formatItem['deviceId'] = item.id
      formatResult.push(formatItem)
    } 
    ctx.body = ctx.helper.successRes(200, formatResult)
  }

  async detail() {
    const { app, ctx } = this
    const uid = this.getUid
    const deviceId = ctx.request.body.deviceId
    const result = await this.service.device.hasDevice(uid, deviceId)
    if (!result) {
      ctx.body = ctx.helper.failRes(403, '你没有这个设备的权限')
      return
    }
    const detail = await this.service.device.getDetail(deviceId)
    if (detail) {
      ctx.body = ctx.helper.successRes(200, detail)
    } else {
      ctx.body = ctx.helper.failRes(500, 'db error')
    }
  }

  async command() {
    const uid = this.getUid()
    const deviceId = ctx.request.body.deviceId 
    const productId = ctx.request.body.productId
    const commandName = ctx.request.body.commandName 
    const commandId = ctx.request.body.commandId
    const result = await this.service.device.hasDevice(uid, deviceId)
    if (!result) {
      ctx.body = ctx.helper.failRes(403, '你没有这个设备权限')
      return
    }
  }

  getUid() {
    let token = this.ctx.request.get('Authorization')
    token = token.replace(/Bearer /, '')
    token = this.app.jwt.decode(token)
    console.log(token)
    return token.uid
  }
}

module.exports = DeviceController;
