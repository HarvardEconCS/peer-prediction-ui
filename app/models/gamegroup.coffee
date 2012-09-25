Spine = require('spine')

class Gamegroup extends Spine.Model
  @configure 'Gamegroup', 'numGames', 'numPlayed', 'playerIds'

  @extend @Local
  
module.exports = Gamegroup