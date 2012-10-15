Spine = require('spine')

Network = require 'network'

GameResultShow = require 'controllers/gameresult_show'
GameInfoShow   = require 'controllers/gameinfo_show'

class Task extends Spine.Controller
  className: 'task'
    
  constructor: ->
    super
    
    @info   = new GameInfoShow
    @result = new GameResultShow
    @append @info, @result
    Network.setControllers @info, @result
    
  active: ->
    super
    
    Network.ready()    
    
  render: ->
    @info.render()
    @result.render()
    
    # # get url parameters
    # getUrlParam: (strParamName) ->
    #   strParamName = escape(unescape(strParamName))
    # 
    #   if $(this).attr("nodeName") is "#document"
    #     if window.location.search.search(strParamName) > -1
    #       qString = window.location.search.substr(1,window.location.search.length).split("&")
    #   else if $(this).attr("src") isnt "undefined"
    #     strHref = $(this).attr("src")
    #     if strHref.indexOf("?") > -1
    #       strQueryString = strHref.substr(strHref.indexOf("?") + 1)
    #       qString = strQueryString.split("&")
    #     else if $(this).attr("href") isnt "undefined"
    #       strHref = $(this).attr("href")
    #       if strHref.indexOf("?") > -1
    #         strQueryString = strHref.substr(strHref.indexOf("?") + 1)
    #         qString = strQueryString.split("&")
    #     else
    #       return null
    # 
    #   return null unless qString
    # 
    #   returnVal = (query.split("=")[1] for query in qString when escape(unescape(query.split("=")[0])) is strParamName)
    # 
    #   if returnVal.lenght is 0
    #     null
    #   else if returnVal.lenght is 1
    #     returnVal[0]
    #   else
    #     returnVal
    
module.exports = Task