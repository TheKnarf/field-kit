FakeEvent = require './fake_event'

class Type
  constructor: (keys...) ->
    @keys = keys

  into: (@field) ->
    @perform()
    return this

  perform: ->
    for key in @keys
      event = FakeEvent.withKey(key)
      event.type = 'keydown'
      @field.keyDown event
      if not event.isDefaultPrevented()
        event.type = 'keypress'
        if event.charCode
          @field.keyPress event
        event.type = 'keyup'
        @field.keyUp event

type = (keys...) ->
  new Type(keys...)

module.exports = { type }
