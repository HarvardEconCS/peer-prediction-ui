Spine = require('spine')

Network = require 'network'

TaskInfo   = require 'controllers/task_info'

class Task extends Spine.Controller
  className: 'task'
      
  constructor: ->
    super
    
    @info   = new TaskInfo
    @append @info
    Network.setControllers @info
    
  active: (params)->
    super
    Network.ready()    
    @render()
        
  render: ->
    return unless @isActive()
    @info.render()
    
module.exports = Task