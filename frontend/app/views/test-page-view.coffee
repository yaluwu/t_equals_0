template = require 'views/templates/grandma'
View = require 'views/base/view'

module.exports = class TestPageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template

  render: ->
    id = window.location.hash

    @$el.html(@template())
