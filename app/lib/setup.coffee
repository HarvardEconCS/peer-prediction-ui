require('json2ify')
require('es5-shimify')
require('jqueryify')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/route')

# Fix IE logging issues
if not window.console
  window.console = 
    log: ->

# window.console = {} unless window.console
# if !window.console.log
#   window.console.log = -> 
