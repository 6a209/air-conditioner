

const Controller = require('egg').Controller;

class UserController extends Controller {

  async login() {
    const { app, ctx } = this
    const wxUser = ctx.request.body
    const user = ctx.service.user.findUser(wxUser.openid) 
    if (user) {
      ctx.service.user.updateUser(wxUser)
    } else {
      ctx.service.user.createUser(wxUser)
    }
    const token = app.jwt.sign({test: 'test'}, app.config.jwt.secret)
    const res = {token: token} 
    ctx.body = ctx.helper.successRes(200, res)
  }
}

module.exports = UserController;