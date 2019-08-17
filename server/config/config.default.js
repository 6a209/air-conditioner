/* eslint valid-jsdoc: "off" */

'use strict';

/**
 * @param {Egg.EggAppInfo} appInfo app info
 */
module.exports = appInfo => {
  /**
   * built-in config
   * @type {Egg.EggAppConfig}
   **/
  const config = {};

  // use for cookie sign key, should change to your own and keep security
  config.keys = appInfo.name + '_1552146144590_158';

  // add your middleware config here
  config.middleware = [];
  config.security = {
    csrf: {
      enable: false
    }
  }
  
  config.jwt = {
    secret: "huahua1945"
  }

  config.oauth2Server = {
    grants: ['authorization_code']
  }

  config.view = {
    defaultViewEngine: 'static',
    mapping: {
      '.html': 'static',
      '.css': 'static',
      '.js': 'static'
    },

  }

  // add your user config here
  const userConfig = {
    // myAppName: 'egg',
  };

  return {
    ...config,
    ...userConfig,
  };
};
