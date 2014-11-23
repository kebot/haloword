require.config({
  baseUrl: '/',
  distUrl:  '/',
  aliases: {
    'haloword': 'javascript/haloword/',
    'ui': 'bower_components/jquery-ui/ui/', # jquery ui
    'jquery': 'bower_components/jquery/src/'
  }
})

define('react', 'bower_components/react/react.js')
define('jquery', 'bower_components/jquery/dist/jquery.js')
define('db', 'bower_components/db.js/src/db.js')
define('underscore', 'bower_components/underscore/underscore.js')

###
require(['react', 'haloword/pages/main'], (React, Main) ->
  React.renderComponent(
    Main(),
    document.getElementById('haloword')
  )
});
###

require ['react', 'haloword/pages/setting'], (React, ConfigPage) ->
  React.renderComponent(ConfigPage(), document.getElementById('haloword'))

