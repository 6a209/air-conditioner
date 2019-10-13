

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

  async register() {

    console.log("register-->>>")
    const { app, ctx } = this
    const mobile = ctx.request.body.mobile
    const password = ctx.request.body.password
    const captcha = ctx.request.body.captcha
    const captchaKey = ctx.request.body.captchaKey
    const nickname = ctx.request.body.nickname


    console.log(ctx.request.body)
    console.log(app.lru)
    if (captcha.toLowerCase() != this.app.lru.get(captchaKey).toLowerCase()) {
      ctx.body = ctx.helper.failRes(500, "验证码错误")
      return
    }


    const user = await this.app.mysql.get('user', { mobile })
    console.log("user => ")
    console.log(mobile)

    console.log(user)
    if (user) {
      ctx.body = ctx.helper.failRes(500, "手机号已经被注册过")
      return
    }

    if (!(/^1[3456789]\d{9}$/.test(mobile))) {
      ctx.body = ctx.helper.failRes(500, "手机号格式错误")
      return
    }
    const newUser = {mobile, password, nickname} 
    const result = await this.service.user.createUser(newUser) 
     
    if (result) {
      const token = app.jwt.sign({ uid: result.insertId }, app.config.jwt.secret)
      newUser.token = token
      delete newUser.password
      ctx.body = ctx.helper.successRes(200, newUser)
    } else {
      ctx.body = ctx.helper.failRes(500, "注册失败")
    }
  }

  async captcha() {
    const { ctx } = this
    const captcha = await ctx.service.user.captcha()
    ctx.body = ctx.helper.successRes(200, captcha)
  }
}

module.exports = UserController;