#!/usr/bin/ruby

require 'json'

folder = ARGV.length ? ARGV[0] : Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
latest = { }
minsize = 9000
images = [ ]
Dir.entries( folder ).each do | f |
  if f !~ /^\./
    stat = File.stat( folder + '/' + f )
    if today == stat.mtime.strftime( '%Y-%m-%d' )
      if stat.size > minsize
      	# puts folder + '/' + f
      	# puts stat.inspect
	latest = f
	images << f
      end
    end
  end
end
images = images.to_json
date = Time.new.to_s
title = 'Motion ' + date
intro = latest
html = <<-end
<html>
  <head>
    <title>#{title}</title>
    <style type="text/css">
      body { font-family: arial, verdana, sans-serif; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="row">
	<div class="col">
	  <h1>#{title}</h1>
	  <p class="intro">#{intro}</p>
	  <div>
	    <img id="image" src="#{latest}" title="#{latest}" />
	    <p id="caption">#{latest}</p>
	  </div>
	</div>
      </div>
    </div>
    <p>By <a href="http://www.clarkeology.com/blog/">Paul Clarke</a>, a work in progress.</p>
    <script type="text/javascript">
      if ( ! window.console ) window.console = { log: function ( ) { alert( arguments ); }};
      var attachEvent = function ( element, event, callback ) {
        if ( element.addEventListener ) {
          element.addEventListener( event, callback, false );
        } else if ( element.attachEvent ) {
          element.attachEvent( 'on' + event, callback );
        }
      };
      var image = document.getElementById( 'image' );
      var caption = document.getElementById( 'caption' );
      var images = #{images};
      var max = images.length - 1;
      var index = max;
      var load = function ( i ) {
        console.log( 'loading image', i );
        if ( i < 0 ) i = max;
        if ( i > max ) i = 0;
        console.log( 'image[', i, '] is ', images[i], 'max is', max );
	if ( images[i] && ( 'jpg' === images[i].substr( -3, 3 ))) {
          caption.innerHTML = images[i];
          image.title = images[i];
          image.src = images[i];
	}
	else {
          caption.innerHTML = 'No preview for ' + images[i];
	}
      };
      attachEvent( document, 'keydown', function ( e ) {
        switch ( e.which || e.keyDown ) {
	  case 37:
	  case 38:
            load( -- index ); break;
	  case 39:
	  case 40:
            load( ++ index ); break;
	}
      } );
    </script>
  </body>
</html>
end
puts html
