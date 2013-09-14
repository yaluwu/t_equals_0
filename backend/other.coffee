
idGeneration = (req, res) ->
  #foo bar


module.exports = (app, io) ->
  app.get '/id-gen', idGeneration
  app.post '/foo-bar', otherFunction