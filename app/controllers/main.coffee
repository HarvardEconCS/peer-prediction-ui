Spine = require('spine')
Network = require 'network'

# models
Player    = require('models/player')
Game      = require('models/game')
Result   = require('models/result')

#controllers
GameResultShow = require('controllers/gameresult_show')
GameInfoShow   = require('controllers/gameinfo_show')

class Main extends Spine.Controller
  className: "main"
  
  constructor: ->
    super
    @setupExp()
    
  setupExp: ->

    # Get turk ID from url parameters
    @currPlayerTurkId = 'turkId3'

    # create game info show controller
    @gameinfoshow = new GameInfoShow turkId: @currPlayerTurkId
  
    # create game results show controller
    @gameresultshow = new GameResultShow turkId: @currPlayerTurkId

    Network.setGameInfo @gameinfoshow, @gameresultshow
    Network.ready()

    # vertical divider
    divide = Spine.$('<div />').addClass('vdivide')
    
    # append controllers
    @append @gameinfoshow, divide, @gameresultshow

    # render controllers
    @gameinfoshow.render()
    @gameresultshow.render()


  # get url parameters
  getUrlParam: (strParamName) ->
    strParamName = escape(unescape(strParamName))

    if $(this).attr("nodeName") is "#document"
      if window.location.search.search(strParamName) > -1
        qString = window.location.search.substr(1,window.location.search.length).split("&")
    else if $(this).attr("src") isnt "undefined"
      strHref = $(this).attr("src")
      if strHref.indexOf("?") > -1
        strQueryString = strHref.substr(strHref.indexOf("?") + 1)
        qString = strQueryString.split("&")
      else if $(this).attr("href") isnt "undefined"
        strHref = $(this).attr("href")
        if strHref.indexOf("?") > -1
          strQueryString = strHref.substr(strHref.indexOf("?") + 1)
          qString = strQueryString.split("&")
      else
        return null

    return null unless qString

    returnVal = (query.split("=")[1] for query in qString when escape(unescape(query.split("=")[0])) is strParamName)

    if returnVal.lenght is 0
      null
    else if returnVal.lenght is 1
      returnVal[0]
    else
      returnVal

module.exports = Main