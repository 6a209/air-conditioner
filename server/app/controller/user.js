

const Controller = require('egg').Controller;

class UserController extends Controller {

  async login() {
    const { app, ctx } = this
    try {
      const mobile = ctx.request.body.mobile
      const password = ctx.request.body.password
      console.log(mobile)
      const user = await ctx.service.user.findUser(mobile, password)
      // if (user) {
      //   ctx.service.user.updateUser(wxUser)
      // } else {
      //   ctx.service.user.createUser(wxUser)
      // }
      const token = app.jwt.sign({ uid: user.id }, app.config.jwt.secret)
      user.token = token;
      delete user.password
      delete user.id
      const res = user 
      ctx.body = ctx.helper.successRes(200, res)
    } catch (err) {
      ctx.body = ctx.helper.failRes(500, err.msg)
    }
  }

  async authorize() {
    const { app, ctx } = this
    if ("GET" == ctx.request.method) {
      await ctx.render("index.html") 
    } else if ("POST" == ctx.request.method) {
    }
  }
}

module.exports = UserController;