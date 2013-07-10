#!/usr/bin/ruby

require 'json'

folder = ARGV.length ? ARGV[0] : Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
latest = { }
minsize = 9000
images = [ ]
files = Dir.entries( folder ).sort_by { |a| File.stat( folder + a ).mtime }
files.each do | f |
  if f !~ /^\./
    if 'jpg' === f[ f.length - 3, f.length - 1 ]
      stat = File.stat( folder + '/' + f )
      if stat.size > minsize
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
      #image-container { position: relative; }
      #highlight { position: absolute; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="row">
	<div class="col">
	  <h1>#{title}</h1>
	  <p class="intro">#{intro}</p>
	  <div id="image-container">
	    <img id="image" src="#{latest}" title="#{latest}" />
	    <p id="caption">#{latest}</p>
	    <div id="highlight"></div>
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
      var highlight = document.getElementById( 'highlight' );
      var images = #{images};
      var max = images.length - 1;
      var index = max;
      var load = function ( i ) {
        if ( i < 0 ) i = max;
        if ( i > max ) i = 0;
	if ( images[i] && ( 'jpg' === images[i].substr( -3, 3 ))) {
          caption.innerHTML = images[i];
          image.title = images[i];
          image.src = images[i];
	  if ( /(\\d+)x(\\d+)-(\\d+)x(\\d+)/.exec( images[i] )) {
	    if ( RegExp.$1 || RegExp.$2 || RegExp.$3 || RegExp.$4 ) {
	      var width = RegExp.$1 / 1;
	      var height = RegExp.$2 / 1;
	      var x = RegExp.$3 / 1;
	      var y = RegExp.$4 / 1;
	      var left = Math.round( x - ( width / 2 ));
	      var top = Math.round( y - ( height / 2 ));
	      console.log( 'draw a box width', width, 'height', height, 'centre', x, y );
	      highlight.style.visibility = 'visible';
	      highlight.style.border = '1px #ff0 dashed';
	      highlight.style.left = left + 'px';
	      highlight.style.top = top + 'px';
	      highlight.style.width = width + 'px';
	      highlight.style.height = height + 'px';
	    }
	    else {
	      highlight.style.visibility = 'hidden';
	    }
	  }
	}
	else {
          caption.innerHTML = 'No preview for ' + images[i];
	}
	return i;
      };
      attachEvent( document, 'keydown', function ( e ) {
        switch ( e.which || e.keyDown ) {
	  case 37:
	  case 38:
            index = load( -- index ); break;
	  case 39:
	  case 40:
            index = load( ++ index ); break;
	}
      } );
    </script>
  </body>
</html>
end
puts html
