#!/usr/bin/ruby

require 'json'

folder = ARGV.length ? ARGV[0] : Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
minsize = 18000
files = Dir.entries( folder ).sort_by { |a| File.stat( folder + a ).mtime }
images = files.reject do | f |
  f[ f.length - 3, f.length - 1 ] != 'jpg'
end
date = Time.new.to_s
title = 'Motion ' + date
html = <<-end
<!DOCTYPE html>
<html>
  <head>
    <title>#{title}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <style type="text/css">
      body { font-family: arial, verdana, sans-serif; }
      h1 { font-size: 1em; }
      p, a.video { font-size: 0.8em; font-weight: normal; }
      #image-container { position: relative; }
      #highlight { position: absolute; display: block; border: 1px #ff0 dashed; z-index: 3; color: #ff0; text-decoration: none; }
      #highlight.hidden { display: none; }
      #prev, #next { position: absolute; left: 0px; top: 0px; width: 512px; height: 576px; float: left; text-indent: 999em; }
      #next { margin-left: 512px; text-align: right; }
      #ads { width: 120px; float: right; margin: 10px; }
      @media (max-width: 800px) {
        h1, p { font-size: 2em; }
        img, #prev, #next { width: 100%; }
      }
      @media (max-width: 1154px) {
        iframe { display: none; }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col">
          <div id="ads">
            <iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="//ws-eu.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&OneJS=1&Operation=GetAdHtml&MarketPlace=GB&source=ss&ref=ss_til&ad_type=product_link&tracking_id=clarkeology-21&marketplace=amazon&region=GB&placement=B00E1GGE40&asins=B00E1GGE40&linkId=MIG4ALJNYCMLNP3U&show_border=true&link_opens_in_new_window=true"></iframe>
            <script data="inline" async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
            <ins class="adsbygoogle"
              style="display:inline-block;width:120px;height:600px"
              data-ad-client="ca-pub-7656534065377065"
              data-ad-slot="2665218693"></ins>
            <script data="inline"> (adsbygoogle = window.adsbygoogle || []).push({}); </script>
          </div>
          <h1><a href="">#{title}</a></h1>
          <p>Way slow, loaded from a <a href="http://www.clarkeology.com/wiki/raspberry+pi">raspberry pi</a> in my house. Hmm, this is why I had to upgrade to fibre...</p>
          <p><a href="https://github.com/pauly/pi-motion">See the repo</a> for how to set up your pi and <a href="http://www.amazon.co.uk/gp/product/B00E1GGE40/ref=as_li_tl?ie=UTF8&camp=1634&creative=19450&creativeASIN=B00E1GGE40&linkCode=as2&tag=clarkeology-21&linkId=ECALLBWP73WQVL7M">camera module</a> like this...</p>
          <div id="image-container">
            <img id="image" src="#{images.slice -1}" title="#{images.slice -1}"  width="1024" height="576" />
            <a id="highlight"></a>
            <a id="prev">&lt;</a>
            <a id="next">&gt;</a>
          </div>
          <p>Click left or left cursor key for the previous image, right for the next. Hmm how do I swipe?</p>
          <div class="previousImages">
            <a href="##{images.slice -2}"><img src="#{images.slice -2}" width="128" height="96" /></a>
            <a href="##{images.slice -3}"><img src="#{images.slice -3}" width="128" height="96" /></a>
            <a href="##{images.slice -4}"><img src="#{images.slice -4}" width="128" height="96" /></a>
            <a href="##{images.slice -5}"><img src="#{images.slice -5}" width="128" height="96" /></a>
            <a href="##{images.slice -6}"><img src="#{images.slice -6}" width="128" height="96" /></a>
            <a href="##{images.slice -7}"><img src="#{images.slice -7}" width="128" height="96" /></a>
            <a href="##{images.slice -8}"><img src="#{images.slice -8}" width="128" height="96" /></a>
          </div>
        </div>
      </div>
    </div>
    <p>Blank image? Looking for a demo? See <a href="http://pauly.github.io/pi-motion/">http://pauly.github.io/pi-motion/</a>...</p>
    <p>By <a href="http://www.clarkeology.com/blog/">Paul Clarke</a>, a work in progress.</p>
    <script type="text/javascript">
      var d = document;
      var attachEvent = function(e, event, callback) {
        if (e.addEventListener) return e.addEventListener(event, callback, false);
        if (e.attachEvent) return e.attachEvent('on' + event, callback);
      };
      var image = d.getElementById('image');
      var highlight = d.getElementById('highlight');
      var files = #{files.to_json};
      var max = files.length - 1;
      var index = max;
      var load = function(i) {
        if (i < 0) i = max;
        if (i > max) i = 0;
        if (! files[i]) return i;
        location.hash = files[i];
        image.title = files[i];
        var extension = files[i].substr(-3, 3);
        if (extension === 'jpg') {
          image.src = files[i];
        }
        highlight.innerHTML = '';
        highlight.className = '';
        if (extension === 'avi') {
          highlight.href = files[i];
          highlight.innerHTML = 'video';
          highlight.className = 'video';
        }
        if (/(\\d+)x(\\d+)-(\\d+)x(\\d+)/.exec(files[i])) {
          if (!(RegExp.$1 && RegExp.$2 && RegExp.$3 && RegExp.$4)) return i;
          var width = RegExp.$1 / 1;
          var height = RegExp.$2 / 1;
          var x = RegExp.$3 / 1;
          var y = RegExp.$4 / 1;
          var left = Math.round(x - (width / 2));
          var top = Math.round(y - (height / 2));
          highlight.style.left = left + 'px';
          highlight.style.top = top + 'px';
          highlight.style.width = width + 'px';
          highlight.style.height = height + 'px';
	  return i;
        }
        highlight.className = 'hidden';
        return i;
      };
      attachEvent(d, 'keydown', function(e) {
        switch (e.which || e.keyDown) {
          case 37:
          case 38:
            e.preventDefault();
            index = load(--index);
            break;
          case 39:
          case 40:
            e.preventDefault();
            index = load(++index);
            break;
        }
      });
      attachEvent(d.getElementById('prev'), 'click', function(e) {
        index = load(--index);
      });
      attachEvent(d.getElementById('next'), 'click', function(e) {
        index = load(++index);
      });

      var startEvent;
      attachEvent(d, 'touchstart', function(event) {
        startEvent = event;
      });
      attachEvent(d, 'touchmove', function(event) {
	event.preventDefault();
        alert('move ' + JSON.stringify(event) + ' ' + JSON.stringify(originalEvent));
      } );
      attachEvent(d, 'touchend', function(event) {
	event.preventDefault();
        alert('end ' + JSON.stringify(event) + ' ' + JSON.stringify(originalEvent));
      });

      if (location.hash) {
        index = load(files.indexOf(location.hash.substr(1)));
      }
    </script>
    <script>var _gaq = _gaq || [];_gaq.push(['_setAccount', 'UA-266418-1']);_gaq.push(['_trackPageview']);(function() {var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);})();</script><script type="text/javascript" src="http://www.google.co.uk/coop/cse/brand?form=cse-search-box&amp;lang=en"></script>
  </body>
</html>
end
puts html
