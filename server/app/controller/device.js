'use strict';

const Controller = require('egg').Controller;

class DeviceController extends Controller {


  async bind() {
    const { app, ctx } = this
    const uid = ctx.request.body.uid
    const deviceId = ctx.request.body.deviceId

    
  }

  /**
   * 首页设备列表
   */
  async list() {

  }

  async detail() {

  }

  async command() {

  }

}