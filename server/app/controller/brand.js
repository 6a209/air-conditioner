'use strict';

const Controller = require('egg').Controller;


class BrandController extends Controller {


  async brandList() {
    const { app, ctx } = this

    const result = await this.service.brand.getBrandList()
    if (result) {
      ctx.body = ctx.helper.successRes(200, result)
    } else {
      ctx.body = ctx.helper.failRes(500, "db error")
    }
  }

  async modeList() {
    const { app, ctx } = this
    const brandId = ctx.request.body.brandId
    const result = await this.service.brand.getBrandMode(brandId)
    if (result) {
      ctx.body = ctx.helper.successRes(200, result)
    } else {
      ctx.body = ctx.helper.failRes(500, "db error")
    }
  } 
}

module.exports = BrandController;