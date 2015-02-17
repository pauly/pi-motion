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
mkdir /var/www/motion
cd /var/www && wget http://www.raspberrypi.org/favicon.ico

# for laundrino
wget https://www.unix-ag.uni-kl.de/~auerswal/ssocr/ssocr-2.16.2.tar.bz2
bunzip2 ssocr-2.16.2.tar.bz2 
tar -xvf ssocr-2.16.2.tar 
cd ssocr-2.16.2/
sudo apt-get install libimlib2 libimlib2-dev
make && sudo make install
