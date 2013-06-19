#!/usr/bin/ruby
folder = Dir.pwd
today = Time.now.strftime '%Y-%m-%d'
latest = { }
minsize = 9000
Dir.entries( folder ).each do | f |
  if f !~ /^\./
    stat = File.stat( folder + '/' + f )
    if today == stat.mtime.strftime( '%Y-%m-%d' )
      if stat.size > minsize
      	puts folder + '/' + f
      	puts stat.inspect
	latest = f
      end
    end
  end
end
p latest
