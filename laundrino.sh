#!/bin/bash
# where to put images
IMGFOLDER=/var/www
# size of picture to take
WIDTH=2000
HEIGHT=2000
# area of interest
CROPWIDTH=200
CROPHEIGHT=100
CROPLEFT=1300
CROPTOP=160
# how much to shift the image to join up the gaps in the lcd reading
XSHIFT=1
YSHIFT=1
/usr/bin/raspistill -sh 100 -co 100 -w ${WIDTH} -h ${HEIGHT} --shutter 9000 -o ${IMGFOLDER}/laundrino.jpg
/usr/bin/convert -crop ${CROPWIDTH}x${CROPHEIGHT}+${CROPLEFT}+${CROPTOP} ${IMGFOLDER}/laundrino.jpg ${IMGFOLDER}/laundrinoCropped.png
SSOCR=`/usr/local/bin/ssocr -f white -b black -d-1 ${IMGFOLDER}/laundrinoCropped.png -o ${IMGFOLDER}/laundrinoSSOCR.png`
# time looks like 1123 as it thinks the : is a 1, can fix this with an ssocr param I think
[[ ${SSOCR} =~ ^[0-9]+$ ]] || exit
HOURS=`expr ${SSOCR#-} / 1000`
MINS=`expr ${SSOCR#-} % 100`
/usr/bin/convert -threshold 20% -negate ${IMGFOLDER}/laundrinoCropped.png ${IMGFOLDER}/laundrinoBlack.png
BLACKBASE64=`cat ${IMGFOLDER}/laundrinoBlack.png | base64 | tr '\n' ' '`
DATE=`date`
MESSAGE="so estimate ${HOURS} hours and ${MINS} minutes remaining"
if [[ "${SSOCR}" -eq "808" ]]; then # special case
  MESSAGE='so looks like washing has just finished'
fi

# @todo hard code an example image in here too for nice demoing

echo "<p><b>Laundrino</b>, <a href=\"http://www.clarkeology.com/m/23238/Laundrino+%28DIY+smart+connected+washing+machine%29\">DIY smart connected washing machine</a>.</p> <p><a href=\"https://www.unix-ag.uni-kl.de/~auerswal/ssocr/\">SSOCR</a> got "${SSOCR}" ${MESSAGE} (as of ${DATE})...</p> <p>Black and white image:</p> <p><img alt=\"Base64 encoded cropped black and white image\" src=\"data:image/png;base64,${BLACKBASE64}\" width=\"${CROPWIDTH}\" height=\"${CROPHEIGHT}\" /></p> <p>Cropped image:</p> <p><img alt=\"cropped image, internal network only\" src=\"laundrinoCropped.png\" width=\"${CROPWIDTH}\" height=\"${CROPHEIGHT}\" /></p> <p>Original image:</p> <p><img alt=\"Original image, internal network only\" src=\"laundrino.jpg\" /></p>" > ${IMGFOLDER}/laundrino.html
[[ ${HOURS} -eq 0 ]] || exit
[[ ${MINS} -gt 0 ]] || exit
[[ ${MINS} -lt 5 ]] || exit
/usr/bin/scp -i /home/pi/mykeypair.pem ${IMGFOLDER}/laundrino.html ec2-user@www.clarkeology.com:/var/www/t/laundrino.html
