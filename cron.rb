#!/usr/bin/ruby

# 42 * * * * find /var/www/motion/ -cmin +2880 -name "*.jpg" -exec rm -f {} \; > /tmp/delete-old-jpg.out 2> /tmp/delete-old-jpg.err
# 43 * * * * find /var/www/motion/ -cmin +360 -name "*.avi" -exec rm -f {} \; > /tmp/delete-old-avi.out 2> /tmp/delete-old-avi.err
# */10 * * * * /home/pi/pi-motion/latest-motion.rb /var/www/motion/ > /var/www/motion/index.html 2> /tmp/latest-motion.err

dir = File.expand_path( File.dirname( __FILE__ ))
executable = dir + '/latest-motion.rb'
crontab = `crontab -l`.split( /\n/ ) || [ ]
crontab = crontab.reject do | line |
  line =~ /motion/
end
crontab << '# new crontab added for ' + dir
puts 'Where to find images? Default /var/www/motion'
outFolder = STDIN.gets.chomp.to_s
outFolder = '/var/www/motion' if outFolder.empty?
puts "Where to write output? Default #{outFolder}/index.html"
outFile = STDIN.gets.chomp.to_s
outFile = "#{outFolder}/index.html" if outFile.empty?
crontab << "42 * * * * find #{outFolder} -cmin +2880 -name '*.jpg' -exec rm -f {} \; > /tmp/delete-old-jpg.out 2> /tmp/delete-old-jpg.err"
crontab << "43 * * * * find #{outFolder} -cmin +360 -name '*.avi' -exec rm -f {} \; > /tmp/delete-old-avi.out 2> /tmp/delete-old-avi.err"
crontab << "*/10 * * * * #{executable} #{outFolder} > #{outFile} 2> /tmp/latest-motion.err"
motion = `which motion`.chomp
crontab << "@reboot #{motion} > /tmp/motion.reboot.out 2> /tmp/motion.reboot.err"
File.open( '/tmp/cron.tab', 'w' ) do | handle |
  handle.write crontab.join( "\n" ) + "\n"
end
puts `crontab /tmp/cron.tab`
puts 'Success!'

