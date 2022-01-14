load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"

begin
;*******************************
; For binary files 
;******************************* 
alg=(/"skm.i.11um_wv","skm.i.generalSplitWindow","skm.i.proposedSplitWindow"/)


yyyy=2000
mm =3
yymm="0003"
iday=12
ihour=17 
mnt=15
iAlg=0

;---Create lat and long coordinate variables
nLat= 501
nLon= 1101
dims= (/nLat,nLon/)
LatS= 25
LatN= 50
LonW= -125
LonE= -70
Lat  = fspan(LatS,LatN,nLat)
Lon  = fspan(LonW,LonE,nLon)

Lon!0= "lon"
Lon@long_name= "lon"
Lon@_FillValue=-999
Lon@units= "degrees-east"
Lon&lon= Lon

Lat!0= "lat"
Lat@long_name = "lat"
Lat@_FillValue =-999.
Lat@units= "degrees_north"
Lat&lat= Lat
   
; **** input GOES-WEST (GOES-10) ****
lst10 = new(dims,"float")
filePath    = "/aosc/helios2/ytma/data_helios2/LST/goes10/lst/"+yymm+"/"
fileName  = filePath+yymm+"_"+mnt+"_"+alg(iAlg) 
print(fileName)
nrec=(iday-1)*24+ihour
lst10 = fbindirread(fileName,nrec,dims, "float")
lst10= lst10(::-1,:)
lst10@_FillValue =-999.
fname10 = fileName
printMinMax(lst10,True)

; **** input GOES-EAST (GOES-8) ****
lst8 = new(dims,"float")
filePath = "/aosc/helios2/ytma/data_helios2/LST/goes8/lst/"+yymm+"/"
fileName = filePath+"/"+yymm+alg(iAlg)
print(fileName)
lst8  = fbindirread(fileName, nrec,dims, "float")
lst8 = lst8(::-1,:)
lst8@_FillValue =-999.
fname8 = fileName
printMinMax(lst8,True)
   
; **** input MODIS data ****   
ddd = day_of_year(yyyy,mm,iday)
print(ddd)
MODpth   = "/data/crash/nshahi/MODIS/"
filenames = systemfunc ("ls "+MODpth+"MOD11_L2.A"+yyyy+sprinti("%0.3i",ddd)+"."+ihour+"*.hdf")
print(filenames)



end
