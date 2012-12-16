Spine = require('spine')

Network   = require 'network'

Homepage  = require 'controllers/homepage'
Tutorial  = require 'controllers/tutorial'
Quiz      = require 'controllers/quiz'
Task      = require 'controllers/task'
Exitsurvey      = require 'controllers/exitsurvey'

class Main extends Spine.Stack
  className: "main stack"
  
  constructor: ->
    super

  controllers:
    homepage: Homepage
    tutorial: Tutorial
    quiz: Quiz
    task: Task
    exitsurvey: Exitsurvey
    
  default: 'homepage'
  
  routes: 
    '/': 'homepage'
    '/tutorial': 'tutorial'
    '/quiz': 'quiz'
    '/task': 'task'
    '/exitsurvey': 'exitsurvey'


module.exports = Main