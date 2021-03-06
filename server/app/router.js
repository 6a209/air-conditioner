'use strict';


/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;

  router.get("/", controller.home.index)
  router.post('/login', controller.user.login)
  router.post('/captcha', controller.user.captcha)
  router.post('/register', controller.user.register)

  // 访问控制 的问题
  // router.post('/device/connect', controller.device.connected)
  router.post('/device/discontected', controller.device.disconected)

  router.post('/device/bind', app.jwt, controller.device.bind);
  router.post('/device/unbind', app.jwt, controller.device.unbind);
  router.post('/device/list', app.jwt, controller.device.list);
  router.post('/device/detail', app.jwt, controller.device.detail);
  router.post('/device/command', app.jwt, controller.device.command);
  router.post('/device/updateName', app.jwt, controller.device.updateDeviceName);
  router.post('/device/bindBrandDevice', app.jwt, controller.device.bindBrandDevice);

  // router.post('/device/createCommand', app.jwt, controller.device.createCommand);

  router.post('/product/list', app.jwt, controller.product.list);
  router.post('/product/commands/create', app.jwt, controller.product.createCommand);
  router.post('/product/commands/update', app.jwt, controller.product.updateCommand);
  router.post('/product/detail', app.jwt, controller.product.productDetail);
  router.post('/product/update', app.jwt, controller.product.update);
  router.post('/product/create', app.jwt, controller.product.create);

  router.post('/brand/list', controller.brand.brandList);
  router.post('/brand/mode',  controller.brand.modeList);

  router.post('/auth/token', app.oAuth2Server.token());
  router.get('/auth/authorize', controller.user.authorize)
  router.post('/auth/authorize', app.oAuth2Server.authorize())
  router.post('/aligenie/command', controller.device.aligenieCommand)
};
