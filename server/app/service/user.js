
const Service = require('egg').Service

class UserService extends Service {

  async findUser(mobile, password) {
    console.log(mobile)
    console.log(password)
    const user = await this.app.mysql.get('user', { mobile })
    console.log(user)
    if (!user) {
      const err = new Error()
      err.msg = "用户不存在"
      throw err;
    }
    if (user.password !== password) {
      const err = new Error()
      err.msg = "密码不正确"
      throw err;
    }
    console.log(user.nickname)
    return user
  }

  async createUser(user) {
    const result = await this.app.mysql.insert('user', user)
    const insertSuccess = result.affectedRows === 1
    return insertSuccess
  }

  async updateUser(user) {
    await this.app.mysql.update('user', user)
    const insertSuccess = result.affectedRows === 1
    return insertSuccess
  }

  async saveAuthorizationCode(client, user, code) {
    // await this.app.mysql.get('oauth', {})
    // await this.app.mysql.update('')
  }
}

module.exports = UserService