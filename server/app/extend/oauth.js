'use strict'

const CLIENT_ID = "20190812"
const CLIENT_SECRET = "72eca5db-b4e9-48b5-9f01-7e8b49791605"

const client = {
  "id": 1,
  "clientId": CLIENT_ID,
  "clientSecret": CLIENT_SECRET,
  "redirectUris": [
    "https://open.bot.tmall.com/oauth/callback"
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
      if (CLIENT_ID != clientId || CLIENT_SECRET != clientSecret) {
        return 
      }
      console.log("return client")
      return client
    };

    async getUser(username, password) {
      const ctx = app.createAnonymousContext();
      const user = await ctx.service.user.findUser(username, password)
      if (user) {
        return { id: user.id }
      }
    };

    async saveAuthorizationCode(code, client, user) {

      // const ctx = app.createAnonymousContext();
      console.log(token)
      console.log(client)
      console.log(user)
      console.log(code)


    }

    async getAuthorizationCode(authorizationCode) {
      console.log(authorizationCode)
    }

    async saveToken(token, client, user) {
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
    }

    async getAccessToken(bearerToken) {
      console.log(bearerToken)
    }
  }

  return Model;

}