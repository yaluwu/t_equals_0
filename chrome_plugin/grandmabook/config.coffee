exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  modules:
    wrapper: (path, data) ->
      """
(function() {
  'use strict';
  #{data}
}).call(this);\n\n
      """

  files:
    javascripts:
      joinTo:
        'grandmabook.js': /^(?:app|vendor)/
      order:
        before: [
          'vendor/console-helper.js',
          'vendor/jquery-1.8.3.js',
          'vendor/underscore-1.4.3.js',
          'vendor/backbone-0.9.10.js'
        ]

  paths:
    public: './'
