crypto = require 'crypto'
_ = require 'underscore'

generateId = (config, req, res) ->
  crypto.randomBytes 16, (ex, buf) ->
    id = buf.toString('base64').replace(/\=+$/, '')
    url = "#{config.HOST}#{config.ROOT}/view/#{encodeURIComponent(id)}"
    res.send {id, url}

module.exports = (config, app, io) ->
  app.post "#{config.ROOT}/id", _.partial(generateId, config)
