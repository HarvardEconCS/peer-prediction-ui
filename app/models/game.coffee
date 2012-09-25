Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'groupId', 'chosenJar', 'done'

  @extend @Local
  
module.exports = Game