template = require 'views/templates/sender'
View = require 'views/base/view'

module.exports = class GrandmaPageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template
  userType: 'sender'
  rendered: false
  grandmaConnected: false
  fileReadyCallback: false
  sending: false
  CHUNK_SIZE: 16002 # Must be divisible by 3 for base64 magic
  files: []

  events:
    "change #files":      "handleInputChange"
    "dragover #drop-zone": "handleDragOver"
    "drop #drop-zone":     "handleDrop"
    "submit .youtube-form":"handleYoutube"

  initialize: (params) ->
    @modelx = params.modelx
    super

    {id, recipient, sender} = @modelx

    @fileReadyCallback = @render

    @recipient = unescape recipient
    @sender = sender
    @sendId = id

    @initSocket()

  initSocket: ->
    @socket = io.connect('//ws.familicircle.com')

    @socket.on 'serverReply', (data) =>
      setTimeout (=>
        @socket.emit 'iamUser', {@userType, @sendId}
      ), 100

    @socket.on 'canIHazFiles', =>
      @grandmaConnected = true
      @fileReadyCallback()

  error: ->
    console.log 'error :('
    @grandmaConnected = false
    @socket.disconnect()
    setTimeout _.bind(@initSocket, @), 5000


  handleInputChange: (e) ->
    console.log 'wtf'
    @handleFiles(e.target.files)
    false


  handleDragOver: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @handleFiles(e.dataTransfer.files)
    false


  handleDrop: (e) ->
    e.stopPropagation()
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'


  handleFiles: (files) ->
    @files.push(files...)
    @sendNextFile()


  handleYoutube: (e) ->
    e.preventDefault()
    link = @$("#youtube-url").val()
    match = link.match /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com(?:\/embed\/|\/v\/|\/watch\?v=|\/watch\?.+&v=))([\w-]{11})(?:.+)?$/
    if match?[1]
      videoId = match[1]

      @socket.emit "fileNew",
        sender: @sender
        type: 'video/youtube'
        size: videoId.length

      @socket.emit 'fileChunk',
        data: videoId
        size: videoId.size

      @socket.emit 'fileClose'

      @$("#youtube-url").val ''

  sendNextFile: ->
    file = @files.pop()
    console.log file
    @socket.emit 'fileNew',
      sender: @sender
      type: file.type
      name: file.name
      size: file.size

    @fileReadyCallback = =>
      @pipeFile file, =>
        @fileReadyCallback = @render
        @socket.emit "fileClose", "awyeah"

  pipeFile: (file, callback, start=0) ->
    reader = new FileReader()
    reader.onloadend = (e) =>
      if e.target.readyState is FileReader.DONE
        amount = Math.min(file.size - start, @CHUNK_SIZE)
        data = e.target.result.substring(13)
        @socket.emit 'fileChunk',
          data: data
          size: amount

        if amount is @CHUNK_SIZE
          @fileReadyCallback = =>
            @pipeFile file, callback, start + @CHUNK_SIZE
        else
          @fileReadyCallback = ->
            callback()


    blob = file.slice(start, start + @CHUNK_SIZE)
    reader.readAsDataURL(blob)


  render: ->
    params = {@recipient, @sender, @grandmaConnected}
    unless _.isEqual params, @lastParams
      @$el.html(@template(params))
      @lastParams = params

    if @files.length
      @sendNextFile()
    @


  sendVideo: (url = 'g85wBkhFhjo') ->
    data = [url]

    meta =
      type: "video/youtube"
      size: url.length
      sender:
        name: "Yalu Wu"
        email: "yaluwu@gmail.com"

    @sendDataz meta, data
