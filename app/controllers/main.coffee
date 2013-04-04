Spine = require('spine')

Network   = require 'network'

Homepage      = require 'controllers/homepage'
Notice        = require 'controllers/notice'
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
    notice : Notice
    tutorial: Tutorial
    quiz: Quiz
    lobby: Lobby
    task: Task
    exitsurvey: Exitsurvey
    errormessage: Errormessage
    
  default: 'homepage'
  
  routes: 
    '/': 'homepage'
    '/notice'   : 'notice' 
    '/tutorial' : 'tutorial'
    '/quiz'     : 'quiz'
    '/lobby'    : 'lobby'
    '/task'         : 'task'
    '/exitsurvey'   : 'exitsurvey'
    '/errormessage' : 'errormessage'


module.exports = Main