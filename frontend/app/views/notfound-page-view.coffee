template = require 'views/templates/notfound'
View = require 'views/base/view'

module.exports = class NotFoundPageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template
