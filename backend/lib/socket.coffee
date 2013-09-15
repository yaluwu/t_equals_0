_ = require('underscore')

connections = {}


handleSender = (socket, id) ->
  console.log "sender connected #{id}"

  if not connections[id]?
    connections[id] = {sender: socket}
  else
    if connections[id].sender?
      closeGracefully(connections[id].sender)
    connections[id].sender = socket

  socket.on 'error', (err) ->
    {grandma, sender} = connections[id]
    if grandma?
      closeGracefully grandma, err
    if sender?
      closeGracefully sender, err

  _.each ['fileNew', 'fileChunk', 'fileClose'], (eventType) ->
    socket.on eventType, (data) ->
      grandma = connections[id]?.grandma

      unless grandma?
        delete connections[id]
        closeGracefully socket, 'grandma missing'
        return

      try
        connections[id].grandma.emit eventType, data
      catch err
        try
          socket.emit 'error', {error: "grandma issues #{err}"}
        catch err2
          # we're fucked
          delete connections[id]
        console.log "Sender #{id} gone"
        delete connections[id]?.sender


handleGrandma = (socket, id) ->
  console.log "grandma connected #{id}"

  socket.on 'error', (err) ->
    {grandma, sender} = connections[id]
    if grandma?
      closeGracefully grandma, err
    if sender?
      closeGracefully sender, err

  sender = connections[id]?.sender
  unless sender?
    closeGracefully socket, 'Could not find sender, perhaps they disconnected?'
    return
  connections[id].grandma = socket
  try
    sender.emit 'grandmaReady', {id}
  catch err
    closeGracefully socket, err

  socket.on 'canIHazFiles', (data) ->
    sender = connections[id]?.sender
    unless sender?
      closeGracefully socket, 'missing sender'
      return
    try
      sender.emit 'canIHazFiles', data
    catch err


closeGracefully = (socket, msg) ->
  try
    socket.emit 'error', {error: "error: #{msg}"}
    socket.end()
  catch err
    console.log "Error when closing #{err}"


module.exports = (config, app, io) ->
  io.sockets.on "connection", (socket) ->
    socket.on 'iamUser', (data) ->
      console.log "got user #{data.userType}"

      switch data.userType
        when 'sender'
          handleSender(socket, data.id)
        when 'grandma'
          handleGrandma(socket, data.id)
    setTimeout (->
      socket.emit 'serverReply', {'here': true}
    ), 100


  setInterval (->
    console.log "There are currently #{_.size connections} active connections."
  ), 1000