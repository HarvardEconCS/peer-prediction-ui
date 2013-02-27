Spine = require('spine')

Network   = require 'network'

Homepage      = require 'controllers/homepage'
Tutorial      = require 'controllers/tutorial'
Quiz          = require 'controllers/quiz'
Lobby         = require 'controllers/lobby'
Task          = require 'controllers/task'
Exitsurvey    = require 'controllers/exitsurvey'
Errormessage  = require 'controllers/errormessage'

class Main extends Spine.Stack
  className: "main stack"
  
  constructor: ->
    super

  controllers:
    homepage: Homepage
    tutorial: Tutorial
    quiz: Quiz
    lobby: Lobby
    task: Task
    exitsurvey: Exitsurvey
    errormessage: Errormessage
    
  default: 'homepage'
  
  routes: 
    '/': 'homepage'
    '/tutorial' : 'tutorial'
    '/quiz'     : 'quiz'
    '/lobby'    : 'lobby'
    '/task'     : 'task'
    '/exitsurvey': 'exitsurvey'
    '/errormessage' : 'errormessage'


module.exports = Main