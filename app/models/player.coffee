Spine = require('spine')

class Player extends Spine.Model
  @configure 'Player', 'turkId', 'qualStatus'

  @extend @Local

  @findByTurkId: (turk_id) ->
    Player.select (p) => p.turkId is turk_id
        

module.exports = Player