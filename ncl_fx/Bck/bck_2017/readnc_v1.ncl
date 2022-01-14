load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;*******************************
; specification and data put in 
;*******************************    
   
  
  
   
   ;o= addfile("./GOES13_BAND_01_20120201_013150.nc","r")
   ;o= addfile("/data/crash/wchen/MODIS/ShortWave/Input/Pr_Wtr/daily/pr_wtr.eatm.2014.nc","r")
   ;o= addfile("/data/crash/mwonsick/GOES10/nc/goes10.2000.366.184514.BAND_01.nc","r")
    o= addfile("/data/crash/ytma/data/raw_nc/2000/goes10.2000.061.004515.BAND_01.nc","r")
    ;print(o)
    ;print(getfilevarnames(o))
     ;pwt = o->pr_wtr
     ;printVarSummary(pwt) 
     ;geoX=o->GeoX
     ;geoY=o->GeoY
     ;printVarSummary(geoX)
     ;printVarSummary(geoY)
     
      lat=o->latitude
      replace_ieeenan(lat,-999.9,0)
      lat@_FillValue=-999.9
      printVarSummary(lat)
      printMinMax(lat,True)

      lon=o->longitude
      replace_ieeenan(lon,-999.9,0)
      lon@_FillValue=-999.9
      printVarSummary(lon)
      printMinMax(lon,True)

   image=o->image
   printVarSummary(image)
     
           
end

