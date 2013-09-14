
app = require('express')()
http = require 'http'
server = http.createServer(app)
io = require("socket.io").listen(server)
crypto = require 'crypto'

io.sockets.on "connection", (socket) ->
  console.log "A socket connected!"

server.listen(process.env.PORT ? 3000)
console.log "Listening on #{process.env.PORT ? 3000}"

app.get '/new-id', (req, res) ->
  crypto.randomBytes 4, (ex, buf) ->
    res.send id: buf.toString('hex')
