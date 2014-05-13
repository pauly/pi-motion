#!/usr/bin/ruby

require 'json'

folder = ARGV.length ? ARGV[0] : Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
minsize = 50000
images = [ ]
files = Dir.entries( folder ).sort_by { |a| File.stat( folder + a ).mtime }
files.each do | f |
  if f !~ /^\./
    if 'jpg' === f[ f.length - 3, f.length - 1 ]
      stat = File.stat( folder + '/' + f )
      if stat.size > minsize
        images << f
      else
        $stderr.puts 'delete ' + f + '???'
      end
    end
  end
end
date = Time.new.to_s
title = 'Motion ' + date
html = <<-end
<!DOCTYPE html>
<html>
  <head>
    <title>#{title}</title>
    <style type="text/css">
      body { font-family: arial, verdana, sans-serif; }
      h1 { font-size: 1em; }
      h2 { font-size: 0.8em; font-weight: normal; }
      #image-container { position: relative; }
      #highlight { position: absolute; }
      #prev, #next { position: absolute; top: 0px; width: 512px; height: 576px; float: left; }
      #next { margin-left: 512px; text-align: right; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col">
          <h1>#{title}</h1>
          <h2>Way slow, loaded from a <a href="http://www.clarkeology.com/wiki/raspberry+pi">raspberry pi</a> in my house. Hmm, this is why my broadband appears so patchy...</h2>
          <div id="image-container">
            <img id="image" src="#{images.slice -1}" title="#{images.slice -1}"  width="1024" height="576" />
            <div id="highlight"></div>
            <a id="prev">&lt;</a>
            <a id="next">&gt;</a>
          </div>
          <h2>Click left or left cursor key for the previous image, right for the next. Hmm how do I swipe?</h2>
          <div class="previousImages">
            <img id="image" src="#{images.slice -2}" title="#{images.slice -2}" width="128" height="96" />
            <img id="image" src="#{images.slice -3}" title="#{images.slice -3}" width="128" height="96" />
            <img id="image" src="#{images.slice -4}" title="#{images.slice -4}" width="128" height="96" />
            <img id="image" src="#{images.slice -5}" title="#{images.slice -5}" width="128" height="96" />
            <img id="image" src="#{images.slice -6}" title="#{images.slice -6}" width="128" height="96" />
          </div>
        </div>
      </div>
    </div>
    <p>By <a href="http://www.clarkeology.com/blog/">Paul Clarke</a>, a work in progress.</p>
    <script type="text/javascript">
      if ( ! window.console ) window.console = { log: function ( ) { alert( arguments ); }};
      var d = document;
      var $ = function ( id ) {
        return d.getElementById(( '' + id ).substr( 1 ));
      };
      var attachEvent = function ( e, event, callback ) {
        if ( e.addEventListener ) return e.addEventListener( event, callback, false );
        if ( e.attachEvent ) return e.attachEvent( 'on' + event, callback );
      };
      var image = $( '#image' );
      var highlight = $( '#highlight' );
      var images = #{images.to_json};
      var max = images.length - 1;
      var index = max;
      var load = function ( i ) {
        if ( i < 0 ) i = max;
        if ( i > max ) i = 0;
        if ( images[i] && ( 'jpg' === images[i].substr( -3, 3 ))) {
          location.hash = images[i];
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
          return i;
        }
        return i;
      };
      attachEvent( d, 'keydown', function ( e ) {
        switch ( e.which || e.keyDown ) {
          case 37:
          case 38:
            index = load( -- index );
            e.preventDefault( );
            break;
          case 39:
          case 40:
            index = load( ++ index );
            e.preventDefault( );
            break;
        }
      } );
      attachEvent( $( '#prev' ), 'click', function ( e ) {
        index = load( -- index );
      } );
      attachEvent( $( '#next' ), 'click', function ( e ) {
        index = load( ++ index );
      } );
      var touchStart = null;
      attachEvent( d, 'touchstart', function ( event ) {
        var err;
        try {
          touchStart = event.originalEvent.touches[0].pageX
        }
        catch ( err ) {
        }
        alert( 'start ' + touchStart + ' ' + JSON.stringify( event ) + ' ' + err );
      } );
      attachEvent( d, 'touchmove', function ( event ) {
        alert( 'move ' + start + JSON.stringify( event ));
      } );
      attachEvent( d, 'touchend', function ( event ) {
        alert( 'end ' + start + JSON.stringify( event ));
      } );
      if ( location.hash ) {
        index = load( images.indexOf( location.hash.substr( 1 )));
      }
    </script>
  </body>
</html>
end
puts html
