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
  "refreshTokenLifetime": 0,
  "accessTokenLifetime": 0,
  "grants": [
    "password", "authorization_code"
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
      console.log(client)
      console.log(user)
      console.log(code)

      const authorizationCode = Object.assign({}, code, { user }, { client });
      console.log("----------->>>")
      console.log(authorizationCode)
      return authorizationCode
    }

    async getAuthorizationCode(authorizationCode) {
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
      return authCode 
    }

    async saveToken(token, client, user) {
      console.log("saveToken")
      const _token = Object.assign({}, token, { user }, { client });

      console.log("---------- saveToken------------")
      console.log(token)
      console.log(client)
      console.log(user)

      return _token 
      // await  
    };


    async revokeAuthorizationCode(code) {
      console.log(code)
      return true
    }

    async getAccessToken(bearerToken) {
      console.log(bearerToken)
    }
  }

  return Model;

}