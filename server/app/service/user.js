
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

  formatDate(expiresDate) {
    const date = new Date(expiresDate)
    return date
  }

  async saveAuthorizationCode(code, client, user) {
    const oauthCode = {
      code: code.authorizationCode,
      expires_at: this.formatDate(code.expiresAt),
      redirect_uri: code.redirectUri,
      uid: user.uid,
      client_id: client.clientId
    }
    const result = await this.app.mysql.insert('oauth_code', oauthCode)
    return result
  }

  async getAuthorizationCode(code) {
    const result = await this.app.mysql.get('oauth_code', {code: code})
    if (!result) return;
    const oauthCode = {
      authorizationCode: result.code,
      expiresAt: result.expires_at,
      redirectUri: result.redirect_uri,
      user: {
        uid: result.uid,
      },
      client: {
        clientId: result.client_id
      }
    }
    return oauthCode 
  }

  async revokeAuthorizationCode(code) {
    await this.app.mysql.delete('oauth_code', {code: code.authorizationCode})
  }

  async saveToken(token, client, user) {
    const oauthToken = {
      access_token: token.accessToken,
      access_expires_at: this.formatDate(token.accessTokenExpiresAt),
      refresh_token: token.refreshToken,
      refresh_expires_at: this.formatDate(token.refreshTokenExpiresAt),
      client_id: client.clientId,
      uid: user.uid
    }
    const result = await this.app.mysql.insert('oauth_token', oauthToken)
    return result
  }

  async getToken(token) {
    const result = await this.app.mysql.get('oauth_token', {access_token: token})
    const oauthToken = {
      accessToken: result.access_token,
      accessTokenExpiresAt: result.access_expires_at,
      refreshToken: result.refresh_token,
      refreshTokenExpiresAt: result.refresh_expires_at,
      user: {
        uid: result.uid
      }
    }
    return oauthToken
  }

  async getUidByToken(token) {
    const result = await this.app.mysql.get('oauth_token', {access_token: token})
    return result.uid
  }
}

module.exports = UserService