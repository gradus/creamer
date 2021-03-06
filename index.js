var cc, fs, hardcode, wrench;

cc = require('coffeecup');

hardcode = require('coffeecup-helpers');

fs = require('fs');

wrench = require('wrench');

exports.attach = function(options) {
  var controller, fn, items, name, registeredViews, self, view, _i, _j, _len, _len2, _ref;
  if (options == null) options = {};
  self = this;
  registeredViews = {};
  if (options.views != null) {
    items = wrench.readdirSyncRecursive(options.views);
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      view = items[_i];
      if (view.match(/(.js|.coffee)/)) {
        fn = require(options.views + '/' + view);
        name = view.split('.').shift();
        registeredViews[name] = fn;
      }
    }
  }
  if (options.controllers != null) {
    items = wrench.readdirSyncRecursive(options.controllers);
    for (_j = 0, _len2 = items.length; _j < _len2; _j++) {
      controller = items[_j];
      if (controller.match(/(.js|.coffee)/)) {
        fn = require(options.controllers + '/' + controller);
        this.router.mount(fn);
      }
    }
  }
  this.bind = function(page, data) {
    var html;
    html = "";
    if (typeof page === 'string') page = registeredViews[page];
    if ((options.layout != null) && typeof page === 'function') {
      hardcode.content = page;
      html = cc.render(options.layout, data, {
        hardcode: hardcode,
        locals: true
      });
    } else if (typeof page === 'function') {
      html = cc.render(page, data, {
        hardcode: hardcode,
        locals: true
      });
    } else {
      '<p>Not Found</p>';
    }
    if (this.res != null) {
      return this.res.html(html);
    } else {
      return html;
    }
  };
  this.registerHelper = function(name, fn) {
    var valid;
    valid = cc.compile(fn, {
      hardcode: hardcode,
      locals: true
    });
    if (typeof fn === 'function') return hardcode[name] = fn;
  };
  this.registerView = function(name, fn) {
    var valid;
    valid = cc.compile(fn, {
      hardcode: hardcode,
      locals: true
    });
    return registeredViews[name] = fn;
  };
  if (((_ref = this.router) != null ? _ref.attach : void 0) != null) {
    return this.router.attach((function() {
      return this.bind = self.bind;
    }));
  }
};

exports.init = function(done) {
  return done();
};
