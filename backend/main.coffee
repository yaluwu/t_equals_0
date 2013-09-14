
app = require('express')()
http = require 'http'
server = http.createServer(app)
io = require("socket.io").listen(server)
crypto = require 'crypto'

io.sockets.on "connection", (socket) ->
  console.log "A socket connected!"

PORT = process.env.PORT ? 3000

server.listen(PORT)

config =
  ROOT: process.env.URI_ROOT ? '/api'
  HOST: process.env.HOST ? "http://localhost:#{PORT}"

console.log "Listening on #{PORT} with app root #{config.ROOT}"

require('./lib/ids')(config, app, io)
