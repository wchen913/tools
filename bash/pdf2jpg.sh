#!/bin/bash

n=0;

echo " ";
echo "Converting:"
echo " ";

for pdffile in *.pdf; do

  ofile=${pdffile%.pdf}.jpg

  echo "$((++n)): $pdffile to $ofile."

  gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -dJPEGQ88 -r600 \
     -sOutputFile=$ofile $pdffile
done

echo " ";
echo "$((n)) files were converted from PDF to PNG format."
