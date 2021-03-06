var express = require('express');
var app = express();
var port = process.env.PORT || 3000;
var server;

app.use(express.static(__dirname + '/test_pages'));
app.use(express.static(__dirname + '/../../../dist'));
app.use(express.static(__dirname + '/../../../node_modules'));

exports.start = function() {
  server = app.listen(port);
  console.log('  :: Server listening on port ' + port + ' ::');
};

exports.stop = function() {
  server.close();
  console.log('  :: Server closed ::');
};

exports.pathFor = function(page) {
  return 'http://localhost:' + port + '/' + page;
};

exports.goTo = function(page) {
  return driver.get(exports.pathFor(page))
    .then(function() {
        if(global.ua) return driver.executeScript('return window.navigator.__defineGetter__("userAgent", ' +
        'function() { return "' + global.ua + '"; });');
    })
    .then(function() {
      return driver.executeScript('window.installFieldKit();');
    });
};
