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
  "authorizationCodeLifetime": 60 * 10,
  "accessTokenLifetime": 60 * 60 * 24,
  "grants": [
     "authorization_code"
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
      const authorizationCode = Object.assign({}, code, { user }, { client });
      console.log(authorizationCode)
      const ctx = app.createAnonymousContext();
      ctx.service.user.saveAuthorizationCode(code, client, user)
      return authorizationCode
    }

    async getAuthorizationCode(authorizationCode) {
      console.log("-----authorizationCode--------")
      console.log(authorizationCode)
      const ctx = app.createAnonymousContext()
      let authCode = await ctx.service.user.getAuthorizationCode(authorizationCode)
      console.log(authCode) 
      authCode = Object.assign({}, authCode,  { client });
      return authCode 
    }

    async saveToken(token, client, user) {
      console.log("---------- saveToken------------")
      console.log(token)
      const _token = Object.assign({}, token, { user }, { client });
      const ctx = app.createAnonymousContext()
      await ctx.service.user.saveToken(token, client, user)
      return _token 
    };


    async revokeAuthorizationCode(code) {
      const ctx = app.createAnonymousContext()
      await ctx.service.user.revokeAuthorizationCode(code)
      return true
    }

    async getAccessToken(bearerToken) {
      console.log("---- getAccessToken ----")
      const ctx = app.createAnonymousContext()
      let token = await ctx.service.user.getToken(bearerToken)
      token = Object.assign({}, token, {client}) 
      return token
    }
  }

  return Model;

}