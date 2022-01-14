load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$nclfx/addmeta.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ modify parameters
yy       = "00"
mm       = "08"
mnt      = "15"
QCm      = "QC10_lsmY" ; QC method
satName  = "goes10"
ivar	 = 1  
day		 = 12  
hour	 = 17 
nrec	 = 0	;(day-1)*nhour+hour
  
;+++ Path & file names & data type
pltpth    = "~/tmp/"
datatype  = "float"

wkstype   = "eps"

;+++ Var Names
input_vars   = (/"skm.i.11um_wv"+"_"+QCm,\
				 "skm.i.11um_sin_an_cfsr_wv_nc"+"_"+QCm,\
				"skm.i.11um_sin_an"+"_"+QCm/)
;+++ Flags
plotFlag  = True

;+++ Parameters   
nhour = 24 
nday  = 31 
nLat= 501
nLon= 1101
geoinfo=(/25,50,-125.,-70/)

dimsz= (/nday,nhour,nLat,nLon/)
dimNames=(/"day","hour","lat","lon"/)

longname="LST"
units="degK"

;+++ Put in Data
data = new(dimsz,datatype)
data@_FillValue =-999.
if isStrSubset("goes8",satName) then
pthin     = "/data/srb3/wchen/LST/GOES_E/output/2000/"+yy+mm+"/"
filename  = pthin+yy+mm+input_vars(1)
wksname   = pltpth+"LST"+"_"+satName+"_"+yy+mm+"_"+hour+input_vars(ivar)
end if
if isStrSubset("goes10",satName) then 
pthin     = "/data/srb3/wchen/LST/GOES_W/output/2000/"+yy+mm+"/"
filename  = pthin+yy+mm+"_"+mnt+"_"+input_vars(ivar)
wksname   = pltpth+"LST"+"_"+satName+"_"+yy+mm+"_"+hour+mnt+"_"+input_vars(ivar)
end if
print(filename)

;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if
data = fbindirread(filename,0,dimsz, datatype)
data = data(:,:,::-1,:)
replace_ieeenan(data,-999.0,0)
printMinMax(data,True)
data     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,-1,-1)
printVarSummary(data)
dataAvg  = dim_avg_n_Wrap(data,0)
printVarSummary(dataAvg)
delete(data)
tmp   = dataAvg(hour,:,:)
delete(dataAvg)
;tmp  = data(day,hour,:,:) 
;tmp  = addmeta(tmp,dimsz(2:3),dimNames(2:3),geoinfo,longname,units,-1,-1) 
;printVarSummary(tmp)


;lat2d   = conform(tmp,Lat,0)
;lon2d   = conform(tmp,Lon,1)
;tmp@lat2d = lat2d
;tmp@lon2d = lon2d
;printMinMax(tmp,True)
;exit
if plotFlag then
   wks = gsn_open_wks(wkstype, wksname)
   gsn_define_colormap(wks,"BlGrYeOrReVi200")             ; choose a color map MPL_jet
  ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); choose a color map

   res                     = True
   res@gsnMaximize         = True              
   res@gsnAddCyclic        = False           
   res@gsnSpreadColors     = True            
  
   res@cnFillOn            = True            
   res@cnFillMode          = "RasterFill"    
   ;res@cnFillMode          = "CellFill"      
   res@cnLinesOn           = False            
   res@cnInfoLabelOn        = False
   res@cnLineLabelsOn       = False

   res@cnLevelSelectionMode = "ManualLevels"
   res@cnLevelSpacingF      = 1;2.5;5
   res@cnMinLevelValF       = 290.
   res@cnMaxLevelValF       = 325.
 

   res@pmTickMarkDisplayMode = "Always"       
   ;res@lbOrientation       = "Vertical"
   res@lbBoxLinesOn        = False   
   ;res@lbLabelAutoStride   = True             
   res@lbBoxSeparatorLinesOn = False
   res@lbLabelStride       = 5
 
   res@mpMinLatF           = geoinfo(0)
   res@mpMaxLatF           = geoinfo(1)
   res@mpMinLonF           = geoinfo(2)
   res@mpMaxLonF           = geoinfo(3)
 
   ;res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   ;res@mpFillOn            = False

   res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
  ;res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   ;res@gsnLeftString       = ""
   ;res@tiMainString        = ""
    
   plot=gsn_csm_contour_map(wks,tmp,res)
   ;draw(plot)
   ;frame(wks)
end if

end
