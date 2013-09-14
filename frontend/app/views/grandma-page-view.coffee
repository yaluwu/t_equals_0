template = require 'views/templates/grandma'
View = require 'views/base/view'

module.exports = class GrandmaPageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template

  initialize: (params) ->
    @modelx = params.modelx
    super

    {id, test} = @modelx
    userType = if test then 'sender' else 'grandma'

    @socket = io.connect()

    @socket.on 'serverReply', (data) =>
      setTimeout (=>
        @socket.emit 'iamUser', {userType, id}
      ), 1000

    @socket.on 'fileNew', _.bind @fileNew, @
    @socket.on 'fileChunk', _.bind @fileChunk, @
    @socket.on 'fileClose', _.bind @fileClose, @
    @socket.on 'error', _.bind @error, @

    @currentFile =
      content: ''

    window.view = @

  error: ->
    console.log 'error :('
    # ['fileNew', 'fileChunk', 'fileClose', 'error'] (from sender)
    # 'canIHazFile' (to sender)

  fileNew: (data) ->
    console.log data

  fileChunk: (data) ->
    console.log data

  fileClose: (data) ->
    console.log data

  render: ->
    @socket.emit 'canIHazFile'
    @$el.html(@template())

  emitEvent: (event, data) ->
    @socket.emit event, data