load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;*******************************
; For binary files 
;******************************* 

     o=addfile("/data/srb4/NAVEEN/modis/Data/HDF/MOD11_aug_montly_mean.nc","r")
     print(o)
     vars=getfilevarnames(o)
     print(vars)  
    data = tofloat(o->LST_Day_CMG)
    data = data*0.02
    data = data(::-1,:)
    data@_FillValue=-999.0
  	nlat  = 3600
  	nlon  = 7200
  	nrec  = 0
  	dims  = (/nlat,nlon/)
   
  
   
       
      lat    = latGlobeF(nlat, "lat", "latitude", "degrees_north")
       
      
      lon    = lonGlobeF(nlon, "lon", "longitude", "degrees_east")
      lon    = (/lon-180./) 
      lon&lon=lon 

      data!0 = "lat"
      data&lat = lat
      data!1= "lon"
      data&lon= lon

     printVarSummary(lon)
     printVarSummary(data)
     tmp=data({25:50},{-125:-70})
     printVarSummary(tmp)
    
  wks  = gsn_open_wks("eps","~/tmp/coneff")
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
  res1                      = True
  ;res1@gsnDraw              = False               
  ;res1@gsnFrame             = False
  res1@gsnMaximize          = True 
 
  res1@gsnSpreadColors      = True              
 ;res1@gsnSpreadColorStart  = 81            
 ;res1@gsnSpreadColorEnd    = 160          
 
  ;res1@gsnRightString            = "MOD11LST"
  ;res1@gsnRightStringFontHeightF = 0.0175
  ;res1@gsnLeftStringFontHeightF  = 0.0175

  res1@cnFillOn             = True                
  res1@cnInfoLabelOn        = False              
  res1@cnLinesOn            = False              
  res1@cnLineLabelsOn       = False
 

  res1@cnLabelMasking            = True
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnLevelSpacingF      =  5
  res1@cnMinLevelValF       = 270.0
  res1@cnMaxLevelValF       = 325.0
  
  ;res1@tmYROn                  = False
  ;res1@tmXTOn                  = False
  ;res1@tmYLMinorOn             = False
  ;res1@tmXBMinorOn             = False

  ;res1@tmYLLabelDeltaF         = -0.65
  ;res1@tmXBLabelDeltaF         = -0.65

  ;res1@tmYLLabelFontThicknessF = 1.75
  ;res1@tmXBLabelFontThicknessF = 1.75
  ;res1@tmYLLabelFontHeightF    = 0.015
  ;res1@tmXBLabelFontHeightF    = 0.015

  ;res1@lbLabelStride           = 2.                
 ;res1@lbOrientation           = "Vertical"          
  ;res1@lbLabelFontHeightF      = 0.0125                
  ;res1@lbLabelFontThicknessF   = 1.75

  ;res1@pmLabelBarWidthF         = 0.8
 ;res1@pmLabelBarHeightF        = 0.05
 ; res1@pmLabelBarOrthogonalPosF = 0.2
 ;res1@pmLabelBarParallelPosF   = 0.5

    ;res1@mpFillOn             = False              
    ; res1@mpCenterLonF         = 0.  
     res1@gsnAddCyclic         = False     
     res1@mpMinLatF            = 25          
     res1@mpMaxLatF            = 50.
     res1@mpMinLonF            = -125
     res1@mpMaxLonF            = -70
   
   plot = gsn_csm_contour_map(wks,tmp,res1)
frame(wks)     
end

