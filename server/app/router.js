'use strict';

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;
  router.get('/', controller.home.index);
  router.post('/login', controller.home.login);
  router.post('/bind', controller.home.bind);
  router.post('/device/list', controller.home.list);
  router.post('/device/detail', controller.home.detail);
  router.post('/command', controller.home.command)
};
