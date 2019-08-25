'use strict'

const CLIENT_ID = "20190812"
const CLIENT_SECRET = "AAB3BB7F9098388E0AD512F544AA6198"

const client = {
  "id": 1,
  "clientId": CLIENT_ID,
  "clientSecret": CLIENT_SECRET,
  "redirectUris": [
    "https://open.bot.tmall.com/oauth/callback?skillId=38698&token=MTY2MjI0NzkwQUZFSElORkRWUQ=="
  ],
<<<<<<< HEAD
  "authorizationCodeLifetime": 60 * 10,
  "grants": [
     "authorization_code"
=======
  "refreshTokenLifetime": 0,
  "accessTokenLifetime": 0,
  "grants": [
    "password", "authorization_code"
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
  ]
} 

module.exports = app => {

  class Model {
    constructor(ctx) { }

    async getClient(clientId, clientSecret) {
      console.log("getClient")
      console.log(clientId)
      console.log(clientSecret)
      if (CLIENT_ID != clientId) {
      // if (CLIENT_ID != clientId || CLIENT_SECRET != clientSecret) {
        return 
      }
      console.log("return client")
      return client
    };

    async getUser(username, password) {
      console.log("======getUser=============")
      console.log(username)
      console.log(password)

      const ctx = app.createAnonymousContext();
      const user = await ctx.service.user.findUser(username, password)
      if (user) {
        return { uid: user.id }
      }
    };

    async saveAuthorizationCode(code, client, user) {
      console.log("========saveAuthorizationCode=====")
<<<<<<< HEAD
      const authorizationCode = Object.assign({}, code, { user }, { client });
      console.log(authorizationCode)
      const ctx = app.createAnonymousContext();
      ctx.service.user.saveAuthorizationCode(code, client, user)
=======
      console.log(client)
      console.log(user)
      console.log(code)

      const authorizationCode = Object.assign({}, code, { user }, { client });
      console.log("----------->>>")
      console.log(authorizationCode)
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
      return authorizationCode
    }

    async getAuthorizationCode(authorizationCode) {
<<<<<<< HEAD
      console.log("-----authorizationCode--------")
      console.log(authorizationCode)
      const ctx = app.createAnonymousContext()
      let authCode = await ctx.service.user.getAuthorizationCode(authorizationCode)
      console.log(authCode) 
      authCode = Object.assign({}, authCode,  { client });
=======
      console.log("authorizationCode")
      console.log(authorizationCode)
      const user = {uid: 2}
      const date = new Date()
      date.setDate(31)
      const code = {
        "expiresAt": date,
        "redirect_uri": "https://open.bot.tmall.com/oauth/callback?skillId=38698&token=MTY2MjI0NzkwQUZFSElORkRWUQ=="
      }
      let authCode = Object.assign({}, code, { user }, { client });
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
      return authCode 
    }

    async saveToken(token, client, user) {
<<<<<<< HEAD
      console.log("---------- saveToken------------")
      console.log(token)
      const _token = Object.assign({}, token, { user }, { client });
      const ctx = app.createAnonymousContext()
      await ctx.service.user.saveToken(token, client, user)
      return _token 
=======
      console.log("saveToken")
      const _token = Object.assign({}, token, { user }, { client });

      console.log("---------- saveToken------------")
      console.log(token)
      console.log(client)
      console.log(user)

      return _token 
      // await  
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
    };


    async revokeAuthorizationCode(code) {
<<<<<<< HEAD
      const ctx = app.createAnonymousContext()
      await ctx.service.user.revokeAuthorizationCode(code)
=======
      console.log(code)
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
      return true
    }

    async getAccessToken(bearerToken) {
<<<<<<< HEAD
      console.log("---- getAccessToken ----")
      const ctx = app.createAnonymousContext()
      let token = await ctx.service.user.getToken(bearerToken)
      token = Object.assign({}, token, {client}) 
      return token
=======
      console.log(bearerToken)
>>>>>>> fda2e5d7fd5d0763ec2bd59a1be2256f5c07d444
    }
  }

  return Model;

}