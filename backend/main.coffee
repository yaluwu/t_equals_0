
app = require('express')()
http = require('http')
server = http.createServer(app)
io = require("socket.io").listen(server)

io.sockets.on "connection", (socket) ->
  console.log "A socket connected!"

server.listen(process.env.PORT ? 3000)
console.log "Listening on #{process.env.PORT ? 3000}"