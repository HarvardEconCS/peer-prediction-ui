

(function(/*! Stitch !*/) {
  if (!this.specs) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath]
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.specs = function(name) {
      return require(name, '');
    }
    this.specs.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.specs.modules = modules;
    this.specs.cache   = cache;
  }
  return this.specs.define;
}).call(this)({
  "controllers/content": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Content', function() {
    var Content;
    Content = require('controllers/content');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/errormessage": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Errormessage', function() {
    var Errormessage;
    Errormessage = require('controllers/errormessage');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/exitsurvey": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Exitsurvey', function() {
    var Exitsurvey;
    Exitsurvey = require('controllers/exitsurvey');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/homepage": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Homepage', function() {
    var Homepage;
    Homepage = require('controllers/homepage');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/intro": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Intro', function() {
    var Intro;
    Intro = require('controllers/intro');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/lobby": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Lobby', function() {
    var Lobby;
    Lobby = require('controllers/lobby');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/main": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Main', function() {
    var Main;
    Main = require('controllers/main');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/network": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Network', function() {
    var Network;
    Network = require('controllers/network');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/notice": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Notice', function() {
    var Notice;
    Notice = require('controllers/notice');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/quiz": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Quiz', function() {
    var Quiz;
    Quiz = require('controllers/quiz');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/status": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Status', function() {
    var Status;
    Status = require('controllers/status');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/tutorial": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Tutorial', function() {
    var Tutorial;
    Tutorial = require('controllers/tutorial');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/game": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Game', function() {
    var Game;
    Game = require('models/game');
    return it('can noop', function() {});
  });

}).call(this);
}
});

require('lib/setup'); for (var key in specs.modules) specs(key);