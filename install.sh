export EDITOR=vi
sudo passwd pi
sudo dpkg-reconfigure tzdata
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git-core apache2 php5 libapache2-mod-php5 libjpeg62 libjpeg62-dev libavformat53 libavformat-dev libavcodec53 libavcodec-dev libavutil51 libavutil-dev libc6-dev zlib1g-dev libmysqlclient18 libmysqlclient-dev libpq5 libpq-dev
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"
git clone https://github.com/pauly/pi-motion.git
sudo cp motion.conf /etc/motion.conf
sudo cp motion /usr/bin
sudo cat /etc/rc.local | sed 's/exit/motion\n\nexit/' > /etc/rc.local
# echo '\ndisable_camera_led=1' >> /boot/config.txt
mkdir /var/www/motion
cd /var/www
wget http://www.raspberrypi.org/favicon.ico
