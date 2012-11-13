Spine = require('spine')

Network   = require 'network'

Tutorial  = require 'controllers/tutorial'
Task      = require 'controllers/task'
Exit      = require 'controllers/exitsurvey'

class Main extends Spine.Stack
  className: "main stack"
  
  constructor: ->
    super

  controllers:
    tutorial: Tutorial
    task: Task
    exit: Exit
    
  default: 'tutorial'
  
  routes: 
    '/task': 'task'
    '/exit': 'exit'
    '/': 'tutorial'

module.exports = Main