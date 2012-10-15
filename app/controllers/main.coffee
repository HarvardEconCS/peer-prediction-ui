Spine = require('spine')
Network = require 'network'

Intro = require 'controllers/intro'
Task = require 'controllers/task'
Exit = require 'controllers/exitsurvey'

class Main extends Spine.Stack
  className: "main stack"
  
  constructor: ->
    super

  controllers:
    intro: Intro
    task: Task
    exit: Exit
    
  default: 'intro'
  
  routes: 
    '/task': 'task'
    '/exit': 'exit'
    '/': 'intro'

module.exports = Main