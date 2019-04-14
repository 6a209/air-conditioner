
'use strict';

const Controller = require('egg').Controller;

class ProductController extends Controller {

  async create() {
    const { app, ctx } = this
    const product = ctx.request.body.product
    console.log(product)
    const result = await this.service.product.createProduct(product)
    ctx.body = ctx.helper.successRes(200)
  }

  async list() {
    const { app, ctx } = this
    const uid = this.getUid()
    const result = await this.service.product.getUserProduct(uid)
    ctx.body = ctx.helper.successRes(200, result)
  }

  async update() {
    const { app, ctx } = this
    const uid = this.getUid()
    const product = ctx.request.body.product
    const pid = product.id
    const result = await this.service.product.hasProduct(uid, pid)
    if (!result) {
      ctx.body = ctx.helper.failRes(403, '你没有这个产品权限')
      return
    }
    await this.service.product.update(product)
    ctx.body = ctx.helper.successRes(200)
  }


  getUid() {
    let token = this.ctx.request.get('Authorization')
    token = token.replace(/Bearer /, '')
    token = this.app.jwt.decode(token)
    console.log(token)
    return token.uid
  }
}

module.exports = ProductController;
