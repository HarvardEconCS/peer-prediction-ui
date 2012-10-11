require('lib/setup')

Spine = require('spine')
Main  = require('controllers/main')
Network = require 'network'

class App extends Spine.Controller
  constructor: ->
    super
    Network.initFake()
    @main = new Main
    @append @main
    
module.exports = App
    