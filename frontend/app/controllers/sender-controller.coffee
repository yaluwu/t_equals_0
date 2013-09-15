Controller = require 'controllers/base/controller'
SenderPageView = require 'views/sender-page-view'

module.exports = class SenderController extends Controller
  index: ({id, recipient, sender}) ->
    @view = new SenderPageView(modelx: {id, recipient, sender})
