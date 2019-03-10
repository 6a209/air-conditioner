'use strict';

const Controller = require('egg').Controller;

class HomeController extends Controller {
  async index() {
    const { ctx } = this;
    ctx.body = 'hi, egg';
  }

  async login() {
    const { app, ctx } = this
    

  }

  async bind() {
    const { app, ctx } = this
    const uid = ctx.request.body.uid
    const deviceId = ctx.request.body.deviceId

    
  }

  async list() {

  }

  async detail() {

  }

  async command() {

  }
}

module.exports = HomeController;
