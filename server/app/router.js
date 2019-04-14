'use strict';

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;
  router.post('/login', controller.user.login);
  router.post('/device/bind', app.jwt, controller.device.bind);
  router.post('/device/list', app.jwt, controller.device.list);
  router.post('/device/detail', app.jwt, controller.device.detail);
  router.post('/device/command', app.jwt, controller.device.command);

  router.post('/product/list', app.jwt, controller.product.list);
  router.post('/product/update', app.jwt, controller.product.update);
  router.post('/product/create', app.jwt, controller.product.create);
};
