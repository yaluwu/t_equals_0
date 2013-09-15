
app = require('express')()
http = require 'http'
server = http.createServer(app)
io = require("socket.io").listen(server,
  'flash policy port': -1
)

io.set 'transports', ['htmlfile', 'xhr-polling', 'jsonp-polling']

crypto = require 'crypto'

PORT = process.env.PORT ? 3000

server.listen(PORT)

config =
  ROOT: process.env.URI_ROOT ? '/api'
  HOST: process.env.HOST ? "http://www.familicircle.com"

console.log "Listening on #{PORT} with app root #{config.ROOT}"

require('./lib/ids')(config, app, io)
require('./lib/socket')(config, app, io)
