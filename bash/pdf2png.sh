#!/bin/bash

n=0;

echo " ";
echo "Converting:"
echo " ";

for pdffile in *.pdf; do

  ofile=${pdffile%.pdf}.png

  echo "$((++n)): $pdffile to $ofile."

  gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -r600 \
     -sOutputFile=$ofile $pdffile
done

echo " ";
echo "$((n)) files were converted from PDF to PNG format."
