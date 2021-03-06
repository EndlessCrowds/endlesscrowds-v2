jQuery(function () {
  var body, controllerClass, controllerName, action;

  body = $('#main_content');
  controllerClass = body.data( "controller-class" );
  controllerName = body.data( "controller-name" );
  action = body.data( "action" );

  function exec(controllerClass, controllerName, action) {
    var ns, railsNS;
    ns = CATARSE;
    railsNS = controllerClass ? controllerClass.split("::").slice(0, -1) : [];

    _.each(railsNS, function(name){
      if(ns) {
        ns = ns[name];
      }
    });

    if ( ns && controllerName && controllerName !== "" ) {
      if(ns[controllerName] && _.isFunction(ns[controllerName][action])) {
        var view = window.view = new ns[controllerName][action]();
      }
    }
  }

  function exec_filter(filterName){
    if(CATARSE.Common && _.isFunction(CATARSE.Common[filterName])){
      CATARSE.Common[filterName]();
    }
  }

  exec_filter('init');
  exec( controllerClass, controllerName, action );
  exec_filter('finish');

  // Loading the editor on the index page fails silently and breaks the nav links.
  if (action == "show") {
    var editor = new wysihtml5.Editor("project_about", { // id of textarea element
      toolbar:      "wysihtml5-toolbar", // id of toolbar element
      parserRules:  wysihtml5ParserRules // defined in parser rules set
    });
  }
});
