'use strict';

const Controller = require('egg').Controller;

class HomeController extends Controller {
  async index() {
    const { ctx } = this;
    ctx.redirect("https://github.com/6a209/air-conditioner") 
    // ctx.body = 'hi, egg';
  }
}

module.exports = HomeController;
