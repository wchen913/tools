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
 
;*******************************
; For binary files 
;******************************* 
;---------- head ---------------
;+++ modify parameters
Tflux = "Tnet"
 	
;=== Path & file names & data type ===
mon   = "JUL";"JAN"
pthin     = "~/Data/DataWeHave/" ;data path
filename1  = pthin+"MeanQnetifr_07.dat"
filename2  = pthin+"MeanQnetwhoi_07.dat"
filename3  = pthin+"MeanQnetsflx_07.dat"
filename4  = pthin+"MeanQneteraint_07.dat";data name

datatype  = "float"
UNDEF     = -9999.

;====== Plot Settings
plotFlag  = True
pltpth    = "~/WORK/Papers/EGU/"         ;figure pth
wksname   = pltpth+Tflux+mon ;figure name
wkstype   = "eps"        ;figure type
 
input_vars   =  "Mean Net Flux"
longname     = "";input_vars 

clim = (/-100,200,2.5/)
lbstrd =20
nplt=4
;=== Parameters ===   
nLat= 257
nLon= 437
;geo information
;geoinfo(0)-geonfo(1):latS-latN
;geoinfo(2)-geoinfo(3):lonW-lonE
geoinfo=(/-34.5,29.5,20.5,129.5/) 

dimsz= (/nLat,nLon/)     ;data size
dimNames=(/"lat","lon"/);dimetion names

 ; data description 
units= "W/m^2" ;data units
figNotes = (/"a","b","c","d","e","f","g","h"/)
figLabel = (/"IFREMER","OAFLUX","SEAFLUX","ERA INTERIM"/)
;monthstr = (/"Jan","Jul","Apr","Oct"/)
;monthstr = (/"January", "February", "March", "April" \
;            ,"May", "June", "July", "August"         \
;            ,"September", "October", "November"      \
;            ,"December" /)
;--------------- Put in Data -------------------------

;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if
;==== readin ssda ====
;longname     = figLabel(0)+" "+input_vars
data1 = new(dimsz,datatype,UNDEF)
data1 = fbindirread(filename1,0,dimsz, datatype)
replace_ieeenan(data1,UNDEF,0)
data1     = addmeta(data1,dimsz,dimNames,geoinfo,longname,units,-1,-1)
printVarSummary(data1)
printMinMax(data1,True)

;longname     = figLabel(1)+" "+input_vars
data2 = new(dimsz,datatype,UNDEF)
data2 = fbindirread(filename2,0,dimsz, datatype)
replace_ieeenan(data2,UNDEF,0)
data2     = addmeta(data2,dimsz,dimNames,geoinfo,longname,units,-1,-1)
printVarSummary(data2)
printMinMax(data2,True) 

;longname     = figLabel(2)+" "+input_vars
data3 = new(dimsz,datatype,UNDEF)
data3 = fbindirread(filename3,0,dimsz, datatype)
replace_ieeenan(data3,UNDEF,0)
data3     = addmeta(data3,dimsz,dimNames,geoinfo,longname,units,-1,-1)
printVarSummary(data3)
printMinMax(data3,True) 


;longname     = figLabel(3)+" "+input_vars
data4 = new(dimsz,datatype,UNDEF)
data4 = fbindirread(filename4,0,dimsz, datatype)
replace_ieeenan(data4,UNDEF,0)
data4     = addmeta(data4,dimsz,dimNames,geoinfo,longname,units,-1,-1)
printVarSummary(data4)
printMinMax(data4,True) 
;--------------- Plotting -------------------------
 
if plotFlag then
   plot = new ( nplt, "graphic") ;Panel Plot
   ;choose a color map;MPL_jet;BlGrYeOrReVi200;ViBlGrWhYeOrRe;
   wks = gsn_open_wks(wkstype, wksname)
   gsn_define_colormap(wks,"BlGrYeOrReVi200")
  ;gsn_define_colormap(wks,"testcmap")    
  ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") 
;; gsn high level interface
   res                     = True
   res@gsnDraw             = False
   res@gsnFrame            = False
   res@gsnMaximize         = True              
   res@gsnAddCyclic        = False           
   res@gsnSpreadColors     = True            
   
;; cn contour 
   res@cnFillOn            = True            
    ;res@cnFillMode          = "RasterFill"    
    ;res@cnFillMode          = "CellFill"      
   res@cnLinesOn            = False            
   res@cnInfoLabelOn        = False
   res@cnLineLabelsOn       = False
   res@cnFillScaleF         = 2.25

   res@cnLevelSelectionMode = "ManualLevels"
   
    
    res@cnMinLevelValF      = clim(0)
    res@cnMaxLevelValF      = clim(1)
    res@cnLevelSpacingF     = clim(2)
    
    res@lbLabelStride       = 25
     
;; tm tick mark 
  ;res@tmXBMajorOutwardLengthF = -0.001
  ;res@tmXBMinorOutwardLengthF = -0.001
  ;res@tmYLMajorOutwardLengthF = -0.001
  ;res@tmYLMinorOutwardLengthF = -0.001
  ;res@tmYRMajorOutwardLengthF = -0.001
  ;res@tmYRMinorOutwardLengthF = -0.001
   
   res@tmYROn                  = False
   res@tmYRLabelsOn            = False
   res@tmXTOn                  = False
   
 
   res@tmYLLabelDeltaF         = -0.35
   res@tmXBLabelDeltaF         = -0.35

   res@tmYLLabelFontThicknessF = 2.5
   res@tmXBLabelFontThicknessF = 2.5

   res@tmYLLabelFontHeightF    = 0.02
   res@tmXBLabelFontHeightF    = 0.02

   ;res@tmYLLabelStride     =  2

;; lb label bar    
   res@lbLabelBarOn        = False      
  ;res@lbOrientation       = "Vertical"       
   res@lbLabelAutoStride   = False             
   res@lbBoxSeparatorLinesOn = False
   res@pmLabelBarWidthF    = 0.6
   res@pmLabelBarHeightF   = 0.1
   ;res@cnLabelBarEndStyle  = "IncludeMinMaxLabels"
   
;; mp maps 
   res@pmTickMarkDisplayMode = "Always" 
   res@mpMinLatF           = -35;geoinfo(0)
   res@mpMaxLatF           = 30;geoinfo(1)
   res@mpMinLonF           = 20;geoinfo(2)
   res@mpMaxLonF           = 130;geoinfo(3)
  ;res@gsnMajorLatSpacing  = 10              ; change maj lat tm spacing
  ;res@gsnMajorLonSpacing  = 20              ; change maj lon tm spacing
  ;res@gsnMinorLatSpacing  = 2.5              ; change maj lat tm spacing
  ;res@gsnMinorLonSpacing  = 4             ; change maj lon tm spacing 
   res@mpCenterLonF        =  0.5*(res@mpMinLonF+res@mpMaxLonF )
   
   res@cnFillDrawOrder             = "PreDraw"
   res@mpOutlineOn                 = True
   res@mpOceanFillColor            = "transparent"
   res@mpLandFillColor             = "white"
   res@mpInlandWaterFillColor      = "white"
   
   res@gsnRightStringOrthogonalPosF = -0.12
   res@gsnRightStringParallelPosF   = 0.85
   
;; panel settings
   resP                            = True 
   resP@gsnMaximize                = True      

   resP@gsnPanelLabelBar           = True 
   resP@lbOrientation       	   = "Vertical"
   resP@lbBoxSeparatorLinesOn      = False
   resP@lbLabelStride              = lbstrd
   resP@pmLabelBarWidthF    = 0.12
   resP@pmLabelBarHeightF   = 0.4
   
   resP@lbLabelFontHeightF  = 0.015
   resP@lbLabelFontThicknessF  = 2.5
   resP@pmLabelBarParallelPosF = 0.025
                 
   resP@gsnPanelYWhiteSpacePercent = 3.
   resP@gsnPanelXWhiteSpacePercent = 3.
   resP@txFontHeightF       = 0.0175 
   
    txres               =  True
    txres@txJust        = "CenterCenter"
    txres@txFontThicknessF = 3.0      ; default=1.00
    txres@txFontHeightF    = 0.04    ; default=0.05
    txres@txFontColor      = "red"
    
    res@gsnRightString        =figLabel(0);figNotes(0)+") "+
    plot(0) = gsn_csm_contour_map_ce(wks,data1,res)
    dum1=gsn_add_text(wks,plot(0),mon,27.5,17.5,txres) 
    
    res@gsnRightString        =figLabel(1);figNotes(1)+") "+
    plot(1) = gsn_csm_contour_map_ce(wks,data2,res)
    
    res@gsnRightString        =figLabel(2);figNotes(2)+") "+
    plot(2) = gsn_csm_contour_map_ce(wks,data3,res)
  
    res@gsnRightString        =figLabel(3);figNotes(3)+") "+
    plot(3) = gsn_csm_contour_map_ce(wks,data4,res)
    
    gsn_panel(wks,plot,(/nplt/2,2/),resP)
    
end if
print("done")

