FakeEvent = require './fake_event'
Caret = require './caret'
{buildField} = require './builders'

class FieldExpectationBase
  into: (@field) ->
    this

  withFormatter: (formatter) ->
    @field.formatter = formatter
    this

  willChange: (@currentDescription) ->
    this

  willNotChange: (@currentDescription) ->
    @to @currentDescription

  to: (@expectedDescription) ->
    @applyDescription()
    @proxyDelegate()
    @perform()
    @assert()
    this

  withError: (errorType) ->
    expect(@actualErrorType).toEqual(errorType)

  applyDescription: ->
    { caret, affinity, value } = Caret.parseDescription @currentDescription
    @field.element.val value
    @field.element.caret caret
    @field.selectionAffinity = affinity

  proxyDelegate: ->
    currentDelegate = @field.delegate()
    @field.setDelegate
      textFieldDidFailToValidateChange: (textField, change, errorType) =>
        @actualErrorType = errorType
        currentDelegate?.textFieldDidFailToValidateChange?(change, errorType)
      textFieldDidFailToParseString: (textField, change, errorType) =>
        @actualErrorType = errorType
        currentDelegate?.textFieldDidFailToParseString?(change, errorType)

  assert: ->
    actual = Caret.printDescription
               caret: @field.element.caret()
               affinity: @field.selectionAffinity
               value: @field.element.val()

    expect(actual).toEqual(@expectedDescription)

  @::__defineGetter__ 'field', ->
    @_field ||= buildField()

  @::__defineSetter__ 'field', (field) ->
    @_field = field

class ExpectThatTyping extends FieldExpectationBase
  constructor: (keys...) ->
    @keys = keys

  perform: ->
    @typeKeys()

  typeKeys: ->
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

class ExpectThatPasting extends FieldExpectationBase
  constructor: (text) ->
    @text = text

  perform: ->
    @paste()

  paste: ->
    event = FakeEvent.pasteEventWithData Text: @text
    @field.paste event

expectThatTyping = (keys...) ->
  new ExpectThatTyping(keys...)

expectThatPasting = (text) ->
  new ExpectThatPasting(text)

module.exports = { expectThatTyping, expectThatPasting }
