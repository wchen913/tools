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

plotFlag = False
yy       = "00"
mm       = "03"
mnt      = 15

input_vars   = (/"ccf","tp2","tp4T","tp5","stz","sza","pwtT"/)

InputPth     = "/aosc/jetstor/ytma/data3/sat/goeswest/lst_input_005_fill/200003/"
PwtPth       = "/aosc/jetstor/ytma/data3/sat/goeswest/pwat/2000/"
PltPth       = "/data/srb1/wchen/WORK/LST/QC/input_check/figs/"
   
wksname      = "LST"
wkstype      = "eps"
day=12
hour=17 


nhour = 24 
nday  = 31 

;---Create lat and long coordinate variables
nLat= 501
nLon= 1101

LatS= 25
LatN= 50
LonW= -125
LonE= -70

dims= (/nday,nhour,nLat,nLon/)

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
   
; **** input  ****
ivar = 1
data = new(dims,"float")
filename  = InputPth+yy+mm+"_"+mnt+"_"+input_vars(1)+".i" 
print(filename)

data = fbindirread(filename,0,dims, "float")
data = data(:,:,::-1,:)
data@_FillValue =-999.
printMinMax(data,True)
tmp  = data(11,16,:,:) 
tmp!0= "lat"
tmp!1= "lon"
tmp&lat =Lat
tmp&lon = Lon
tmp@units=" "
tmp@long_name = input_vars(ivar)
;lat2d   = conform(tmp,Lat,0)
;lon2d   = conform(tmp,Lon,1)
;tmp@lat2d = lat2d
;tmp@lon2d = lon2d
printMinMax(tmp,True)
;exit
 wks = gsn_open_wks(wkstype, wksname)

   gsn_define_colormap(wks,"NCV_jet")             ; choose a color map
  ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); choose a color map

   res                     = True
   res@gsnMaximize         = True            ; ps, pdf, pdf    
   res@gsnAddCyclic        = False           ; data not cyclic
   res@gsnSpreadColors     = True            ; use full colormap
  
   res@cnFillOn            = True            ; turn on color
   res@cnFillMode          = "RasterFill"    ; raster mode
   ;res@cnFillMode          = "CellFill"     ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
   res@lbOrientation       = "Vertical"      ; vertical label bar
   res@lbLabelAutoStride   = True            ; let NCL decide spacing
   res@lbBoxSeparatorLinesOn = False

  ;res@cnLevelSelectionMode = "ManualLevels"
  ;res@cnLevelSpacingF      = (400-100)/64
  ;res@cnMinLevelValF       = 100.
  ;res@cnMaxLevelValF       = 400.
 
   res@mpMinLatF           = LatS     ; region to zoom in on
   res@mpMaxLatF           = LatN
   res@mpMinLonF           = LonW
   res@mpMaxLonF           = LonE

   res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   res@mpFillOn            = False

   res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
  ;res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   res@gsnLeftString       = ""
   res@tiMainString        = ""
     
   plot=gsn_csm_contour_map_ce(wks,tmp,res)
   ;draw(plot)
   ;frame(wk)


end
