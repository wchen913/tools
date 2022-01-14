;**********************************************************************
; poly_15.ncl
;
; Concepts illustrated:
;   - Drawing polymarkers at station locations 
;**********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$nclfx/addmeta.ncl"
begin

  mplatN = 30.0
  mplatS = -30.0
  mplonL  = 50.0
  mplonR  = 110.0

   ORG      = "RAMA"
  
   lat      = (/-2,-8,-8,-12,   0,  -4,  -8,-1.5, 0,1.5,12,15,-5,-8/)
   lon      = (/55,55,67, 67,80.5,80.5,80.5,  90,90, 90,90,90,95,95/)
   latln    = fspan(mplatS+0.5,mplatN-0.5,60)
   lonln    = fspan(mplonL+0.5,mplonR-0.5,60)
   nlat     = dimsizes(latln)
   nlon     = dimsizes(lonln)

   pltpth   = "~/tmp/"
   wkstype  = "eps"
   wksname  = pltpth+ORG+"_14Sites_Location"
   tistr    = ORG+" 14Site Location"
;**********************************************************
;**********************************************************
  wks = gsn_open_wks(wkstype,wksname)

  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnMaximize                 = True    ; affects ps, eps, pdf only
  res@gsnPaperOrientation         = "portrait"  ; force portrait 

  res@tiMainString                =  tistr

  res@mpMinLatF                   = mplatS    ; range to zoom in on
  res@mpMaxLatF                   = mplatN 
  res@mpMinLonF                   = mplonL
  res@mpMaxLonF                   = mplonR
  res@mpCenterLonF                = (mplonL+mplonR)*0.5

  res@mpFillOn                    =  True
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOceanFillColor            = "dodgerblue"
  res@mpLandFillColor             = "sandybrown";"tan";
  ;res@mpFillBoundarySets          = "National";"AllBoundaries"
  ;res@mpOutlineBoundarySets       = "AllBoundaries";"GeophysicalAndUSStates"
  ;res@mpUSStateLineColor          = "Gray10"
  ;res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"
;
; Draw the map (frame won't get advanced because gsnFrame was set to False).
;
  map = gsn_csm_map(wks,res)
;
; Draw markers on the plot in the lat/lon locations.
;
  mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
;NhlNewMarker(wks,"u",34,0.0,0.0,1.3125,1.5,0.0);filled triangle
  mkres@gsMarkerSizeF = 0.04
  mkres@gsMarkerColor = "red"
  

  map@locations = gsn_add_polymarker(wks,map,lon,lat,mkres)

   dum = new(dimsizes(lonln),graphic)
  do i = 0,nlon-1
    dum(i) = gsn_add_polyline(wks,map,(/lonln(i),lonln(i)/),(/latln(0),latln(nlat-1)/),False)
  end do
;************************************************
; draw longitude lines
;************************************************
  dum1 = new(dimsizes(latln),graphic)
  do i = 0 ,nlat-1
    dum1(i) = gsn_add_polyline(wks,map,(/lonln(0),lonln(nlon-1)/),(/latln(i),latln(i)/),False)
  end do

  draw(map)
  frame(wks)   ; Now advance the frame.
end
 ;pthin	= "/data/crash/wchen/RAMA/cdf/fields/"
   ;filename	= "rad_xyt_mon.cdf" 
   ;fid		= addfile(pthin+filename,"r")
   ;lat      = fid->lat
   ;lon      = fid->lon
