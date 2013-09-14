Controller = require 'controllers/base/controller'
GrandmaPageView = require 'views/grandma-page-view'

module.exports = class GrandmaController extends Controller
  index: ({id}) ->
    @view = new GrandmaPageView(modelx: {id})
  test: ({id}) ->
    @view = new GrandmaPageView(modelx: {id: id, test: true})