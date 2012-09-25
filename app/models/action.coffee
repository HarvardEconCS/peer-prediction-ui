Spine = require('spine')

class Action extends Spine.Model
  @configure 'Action', 'gameId', 'playerId', 'signal', 'action', 'refPLayer', 'reward'

  @extend @Local
  
module.exports = Action