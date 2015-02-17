echo "export EDITOR=vi" >> ~/.profile
sudo passwd pi
sudo dpkg-reconfigure tzdata
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git-core apache2 php5 libapache2-mod-php5 libjpeg62 libjpeg62-dev libavformat53 libavformat-dev libavcodec53 libavcodec-dev libavutil51 libavutil-dev libc6-dev zlib1g-dev libmysqlclient18 libmysqlclient-dev libpq5 libpq-dev
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"
cd && git clone https://github.com/pauly/pi-motion.git && cd pi-motion
./cron.rb
cd /etc && sudo ln -s ~/pi-motion/motion.conf . && cd ~/pi-motion
cd /usr/sbin && sudo ln -s ~/pi-motion/motion . && cd ~/pi-motion
# cat /etc/rc.local | sudo sed 's/exit/motion\n\nexit/' > /etc/rc.local
# sudo cp ~/pi-motion.sh /etc/init.d
mkdir /var/www/motion
cd /var/www && wget http://www.raspberrypi.org/favicon.ico
