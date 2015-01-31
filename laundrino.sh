#!/bin/bash
/usr/bin/raspistill -sh 100 -co 100 -w 1000 -h 1000 --shutter 10000 -o /var/www/laundrino.jpg
/usr/bin/convert -crop 300x50+600+100 /var/www/laundrino.jpg /var/www/laundrinoCropped.png
/usr/bin/convert -threshold 10% -negate -median 2 /var/www/laundrinoCropped.png /var/www/laundrinoBlack.png
/usr/bin/composite -compose Multiply -geometry +0+2 /var/www/laundrinoBlack.png /var/www/laundrinoBlack.png /var/www/laundrinoDouble.png
/usr/bin/tesseract -psm 8 /var/www/laundrinoDouble.png /var/www/display
cat /var/www/display.txt
