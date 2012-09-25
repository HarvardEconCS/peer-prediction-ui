Spine = require('spine')

class Player extends Spine.Model
  @configure 'Player', 'turkId', 'qualStatus'

  @extend @Local
      
module.exports = Player