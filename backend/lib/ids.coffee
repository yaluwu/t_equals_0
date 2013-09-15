crypto = require 'crypto'
_ = require 'underscore'

generateId = (config, req, res) ->
  crypto.randomBytes 16, (ex, buf) ->
    id = buf.toString('base64').replace(/\=+$/, '').replace(/\//g, '')
    url = "#{config.HOST}/shared/#{encodeURIComponent(id)}"
    res.send {id, url}

module.exports = (config, app, io) ->
  app.post "#{config.ROOT}/id", _.partial(generateId, config)
