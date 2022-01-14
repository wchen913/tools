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
 datapth     = "/data/crash/wchen/"
 workpth     = "/data/srb1/wchen/WORK/"
;*******************************
; For binary files 
;******************************* 
 
 vName       = "ssda"

InputPth     = datapth+"merge_cut_data/" 
OutPth       = InputPth
wkstype      = "x11"
wksname      = "test"

;---Create lat and long coordinate variables
ntime = 138

nLat  = 180
nLon  = 360

LatS= -89.5
LatN= 89.5
LonW= -179.5
LonE=  179.5

YYMM = yyyymm_time(2002,2013,"integer")
yymm = YYMM({200207:201312})
delete(YYMM)
 

dims= (/ntime,nLat,nLon/)

Lat  = fspan(LatS,LatN,nLat)
Lon  = fspan(LonW,LonE,nLon)

Lon!0= "lon"
Lon@long_name= "lon"
Lon@_FillValue=-9999
Lon@units= "degrees-east"
Lon&lon= Lon

Lat!0= "lat"
Lat@long_name = "lat"
Lat@_FillValue =-9999.
Lat@units= "degrees_north"
Lat&lat= Lat
   
; **** input  ****
 
data = new(dims,"float")
filename  =  ""
print(filename)

data = fbindirread(filename,0,dims, "float")
data = data(:,::-1,:)
data@_FillValue =-9999.
printMinMax(data,True)
tmp  = data(1,:,:) 
tmp!0= "lat"
tmp!1= "lon"
tmp&lat =Lat
tmp&lon = Lon
tmp@units=" "
tmp@long_name = input_vars(ivar)
 
 
printMinMax(tmp,True)
;exit
wks = gsn_open_wks(wkstype, wksname)

 
   
   res                     = False
  

   plot=gsn_csm_contour_map_ce(wks,tmp,res)
   ;draw(plot)
   ;frame(wk)


end
