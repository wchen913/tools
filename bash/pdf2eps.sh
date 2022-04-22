#!/bin/bash

n=0;

echo " ";
echo "Converting:"
echo " ";

for pdffile in *.pdf; do

  ofile=${pdffile%.pdf}.eps

  echo "$((++n)): $pdffile to $ofile."

  pdftops -eps $pdffile $ofile
done

echo " ";
echo "$((n)) files were converted from PDF to EPS format."
