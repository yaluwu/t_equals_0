Controller = require 'controllers/base/controller'
NotFoundView = require 'views/notfound-page-view'

module.exports = class NotFoundController extends Controller
  index: ->
    @view = new NotFoundView()
