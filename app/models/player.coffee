Spine = require('spine')

class Player extends Spine.Model
  @configure 'Player', 'turkId', 'qualStatus'

  @loadData: (turk_id) ->
    

  @extend @Local

  
                  
module.exports = Player