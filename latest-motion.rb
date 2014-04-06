#!/usr/bin/ruby

require 'json'

folder = ARGV.length ? ARGV[0] : Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
minsize = 9000
images = [ ]
files = Dir.entries( folder ).sort_by { |a| File.stat( folder + a ).mtime }
files.each do | f |
  if f !~ /^\./
    if 'jpg' === f[ f.length - 3, f.length - 1 ]
      stat = File.stat( folder + '/' + f )
      if stat.size > minsize
        images << f
      end
    end
  end
end
date = Time.new.to_s
title = 'Motion ' + date
html = <<-end
<html>
  <head>
    <title>#{title}</title>
    <style type="text/css">
      body { font-family: arial, verdana, sans-serif; }
      h1 { font-size: 1em; }
      #image-container { position: relative; }
      #highlight { position: absolute; }
      #prev, #next { position: absolute; top: 0px; width: 320px; height: 480px; float: left; }
      #next { margin-left: 320px; text-align: right; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col">
          <h1>#{title}</h1>
          <div id="image-container">
            <img id="image" src="#{images.slice -1}" title="#{images.slice -1}"  width="640" height="480" />
            <p id="caption">#{images.slice -1}</p>
            <div id="highlight"></div>
            <a id="prev">&lt;</a>
            <a id="next">&gt;</a>
          </div>
          <p class="intro">Click left or left cursor key for the previous image, right for the next. Hmm how do I swipe?</p>
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
      var images = #{images.to_json};
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
      attachEvent( document.getElementById( 'prev' ), 'click', function ( e ) {
        index = load( -- index );
      } );
      attachEvent( document.getElementById( 'next' ), 'click', function ( e ) {
        index = load( ++ index );
      } );
      var touchStart = null;
      attachEvent( document, 'touchstart', function ( event ) {
        var err;
        try {
          touchStart = event.originalEvent.touches[0].pageX
        }
        catch ( err ) {
        }
        alert( 'start ' + touchStart + ' ' + JSON.stringify( event ) + ' ' + err );
      } );
      attachEvent( document, 'touchmove', function ( event ) {
        alert( 'move ' + start + JSON.stringify( event ));
      } );
      attachEvent( document, 'touchend', function ( event ) {
        alert( 'end ' + start + JSON.stringify( event ));
      } );

    </script>
  </body>
</html>
end
puts html
