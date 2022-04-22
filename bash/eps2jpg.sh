#!/bin/bash
#
#
# 130325,Mayingtao: changed 'convert' to 'gs', qulity is better, 
#        especially the broken line problem get solved! 
# 130124,Mayingtao:
#  Windows GhostView > eps2png.sh > esp2jgp.sh
# *.png sometime has line problem,
# *.jpg has color problem, and file size is too big even with qulity=75.
#
# ----------------------
# * The -dBATCH -dNOPAUSE options in the examples above disable 
#   the interactive prompting
#
# * http://ghostscript.com/doc/current/Devices.htm#PNG
#
# * Ghostscript provides a variety of devices for PNG output varying by
#   bit depth. For normal use we recommend png16m for 24-bit RGB color,
#   or pnggray for grayscale. The png256, png16 and pngmono devices 
#   respectively provide 8-bit color, 4-bit color and black-and-white 
#   for special needs. The pngmonod device is also a black-and-white 
#   device, but the output is formed from an internal 8 bit grayscale 
#   rendering which is then error diffused and converted down to 1bpp.
#   The pngalpha device is 32-bit RGBA color with transparency 
#   indicating pixel coverage.

n=0;

echo " ";
echo "Converting:"
echo " ";

for epsfile in *.eps; do

  ofile=${epsfile%.eps}.jpg

  echo "$((++n)): $epsfile to $ofile."

  #convert -density 300x300 -quality 92 $epsfile $ofile
  gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -dJPEGQ=100 -r300 \
     -sOutputFile=$ofile $epsfile
done

echo " ";
echo "$((n)) files were converted from EPS to PNG format."
