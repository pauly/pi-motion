#!/bin/bash
[[ "$(ps -ef | grep ${0} | grep -c -v 'grep')" -gt 3 ]] && exit 1
# where to put images
IMGFOLDER=/var/www
# size of picture to take
WIDTH=2000
HEIGHT=2000
# take a picture
/usr/bin/raspistill -sh 100 -co 100 -w ${WIDTH} -h ${HEIGHT} --shutter 9000 -o ${IMGFOLDER}/laundrino.jpg
# get coordinates of interesting part of picture (the clock)
CROPINFO=`convert ${IMGFOLDER}/laundrino.jpg -virtual-pixel edge -blur 0x10 -fuzz 15% -trim -format '%wx%h%O' info:`
CROPWIDTH=`echo ${CROPINFO} | cut -d+ -f1 | cut -dx -f1`
CROPHEIGHT=`echo ${CROPINFO} | cut -d+ -f1 | cut -dx -f2`
/usr/bin/convert ${IMGFOLDER}/laundrino.jpg -crop ${CROPINFO} +repage ${IMGFOLDER}/laundrinoCropped.png
SSOCR=`/usr/local/bin/ssocr -n 4 -f white -b black -d-1 ${IMGFOLDER}/laundrinoCropped.png -o ${IMGFOLDER}/laundrinoSSOCR.png`
>&2 echo "'${SSOCR}'"
# time looks like 1123 as it thinks the : is a 1, can fix this with an ssocr param I think
[[ ${SSOCR} =~ [0-9] ]] || exit
# HOURS=`echo ${SSOCR} | cut -d_ -f1`
# MINS=`echo ${SSOCR} | cut -d_ -f2`
HOURS=`expr ${SSOCR#-} / 1000`
MINS=`expr ${SSOCR#-} % 100`
[[ ${MINS} =~ [0-9] ]] || exit
>&2 echo "${HOURS} hours"
>&2 echo "${MINS} mins"
/usr/bin/convert -threshold 20% -negate ${IMGFOLDER}/laundrinoCropped.png ${IMGFOLDER}/laundrinoBlack.png
BASE64=`cat ${IMGFOLDER}/laundrinoBlack.png | base64 | tr '\n' ' '`
DATE=`date`
MESSAGE="${HOURS} hours, ${MINS} minutes to go"
if [[ "${SSOCR}" == "_0_" ]]; then # special case
  MESSAGE='looks like washing has just finished'
fi
if [[ "${SSOCR}" == "-0_" ]]; then # special case
  MESSAGE='looks like washing has just finished'
fi

echo "<p><a href=\"http://www.clarkeology.com/project/laundrino\">Laundrino</a>, <a href=\"http://www.clarkeology.com/m/23238/Laundrino+%28DIY+smart+connected+washing+machine%29\">DIY smart connected washing machine</a>.</p> <p><a href=\"https://www.unix-ag.uni-kl.de/~auerswal/ssocr/\">SSOCR</a> got "${SSOCR}" so ${MESSAGE} (as of ${DATE})...</p> <p>Black and white image:</p> <p><img alt=\"Base64 encoded cropped black and white image\" src=\"data:image/png;base64,${BASE64}\" width=\"${CROPWIDTH}\" height=\"${CROPHEIGHT}\" /></p> <p>Original image:</p> <p><img alt=\"Original smart trimmed image, internal network only\" src=\"laundrinoCropped.png\" /></p><p>Here's a sample cropped image so you can see what I'm working with:</p><p><img alt=\"Sample Base64 encoded cropped black and white image\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADsAAAAnAQAAAACZSg3+AAAABGdBTUEAALGPC/xhBQAAAAFzUkdC AK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAJiS0dE AAHdihOkAAAACXBIWXMAAAsSAAALEgHS3X78AAAAmklEQVQY02P4DwEPGIhj/GD8/4AfxPjA8P8A M5TRAGXMP8D+gOHn/x5mmQSgmg/1bPt47P+DGOx/EAx5FEYyjJGIwUhm/wfW9aO+/T+PgfwDhn// 5//fD7Ed5Bpkxof//f/kH3CAdLX/4///IwFsMv//D1gZ9VgYUF317P/5vwMZP4C+ABqYAPby/gMw Lzewo3gZGBoH2PGFGADkZtm1v/vAZAAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wMi0yM1QxNToy MTowMiswMDowMBihG3gAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDItMjNUMTU6MjE6MDIrMDA6 MDBp/KPEAAAAEXRFWHRqcGVnOmNvbG9yc3BhY2UAMix1VZ8AAAAgdEVYdGpwZWc6c2FtcGxpbmct ZmFjdG9yADJ4MiwxeDEsMXgxSfqmtAAAAABJRU5ErkJggg== \" width=\"59\" height=\"\" /></p>" > ${IMGFOLDER}/laundrino.html
echo "{\"message\":\"${MESSAGE} (as of ${DATE})\"}" > ${IMGFOLDER}/laundrino.json
[[ ${HOURS} -eq 0 ]] || exit
[[ ${MINS} -gt 1 ]] || exit
[[ ${MINS} -lt 5 ]] || exit
/usr/bin/scp -i /home/pi/mykeypair.pem ${IMGFOLDER}/laundrino.html ec2-user@www.clarkeology.com:/var/www/t/laundrino.html
