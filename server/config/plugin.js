'use strict';

/** @type Egg.EggPlugin */
module.exports = {
  // had enabled by egg
  // static: {
  //   enable: true,
  // }
  jwt: {
    enable: true,
    package: "egg-jwt"
  },

  mysql: {
    enable: true,
    package: 'egg-mysql'
  },

  redis:  {
    enable: true,
    package: 'egg-redis'
  },

  oauth2Server: {
    enable: true,
    package: 'egg-oauth2-server'
  },

  viewStatic:  {
    enable: true,
    package: 'egg-view-static',
  },

  lru: {
    enable: true,
    package: 'egg-lru'
  }
};
