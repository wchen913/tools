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
;---------- head ---------------
;+++ modify parameters
 	yrStrt=1983
 	mmStrt=7
	;ddStrt= 1
 	yrEnd =2012
 	mmEnd = 12
	;ddEnd = 31 
 	nplt  = 6
 
 	yyyymmpltStrt=201007
;=== Path & file names & data type ===
pthin     = "/data/pkgroup2/zhang/results_dx3.4/" ;data path
filename  = pthin+"PacificEq_monthly_biascorrected02-04_dx_modis_sda_83_12.dat" ;data name
datatype  = "float"
print(filename)

pltpth    = "~/tmp/"    ;figure pth
wksname   = pltpth+"x1" ;figure name
wkstype   = "eps" ; figure type
;=== Var Names ===
input_vars   =  "ssda"
;=== Flags ===
plotFlag  = True
;=== Parameters ===   
ntime=354
nLat= 60
nLon= 160
;geo information
;geoinfo(0)-geonfo(1):latS-latN
;geoinfo(2)-geoinfo(3):lonW-lonE
geoinfo=(/-29.5,30,120.5,280./) 

dimsz= (/ntime,nLat,nLon/)     ;data size
dimNames=(/"time","lat","lon"/);dimetion names
Time = yyyymm_time(yrStrt,yrEnd,"integer") ;generate time stamp
time=Time({yrStrt*100+mmStrt:yrEnd*100+mmEnd}); data time stamp
delete(Time)
longname="monthly mean surface shortwave downward flux Anomalies" ; data description 
units="W^2" ;data units
figNotes = (/"a","b","c","d","e","f","g","h"/)
monthstr = (/"January", "February", "March", "April" \
            ,"May", "June", "July", "August"         \
            ,"September", "October", "November"      \
            ,"December" /)
;--------------- Put in Data -------------------------
data = new(dimsz,datatype)
data@_FillValue =-1000.

;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if
data = fbindirread(filename,0,dimsz, datatype)
;replace_ieeenan(data,-1000.0,0)
printMinMax(data,True)
data     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(data)
;--------------- Plotting -------------------------
 
if plotFlag then
   plot = new ( nplt, "graphic") ;Panel Plot
   ;choose a color map;MPL_jet;BlGrYeOrReVi200;ViBlGrWhYeOrRe;
   wks = gsn_open_wks(wkstype, wksname)
   gsn_define_colormap(wks,"testcmap")    
  ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") 
;; gsn high level interface
   res                     = True
   res@gsnDraw              = False
   res@gsnFrame             = False
   res@gsnMaximize         = True              
   res@gsnAddCyclic        = False           
   res@gsnSpreadColors     = True            
   
;; cn contour 
   res@cnFillOn            = True            
   ;res@cnFillMode          = "RasterFill"    
   ;res@cnFillMode          = "CellFill"      
   res@cnLinesOn           = False            
   res@cnInfoLabelOn        = False
   res@cnLineLabelsOn       = False

   res@cnLevelSelectionMode = "ManualLevels"
   res@cnLevelSpacingF      = 2
   res@cnMinLevelValF       = -60.
   res@cnMaxLevelValF       = 60.
;; tm tick mark 
   res@tmYROn                  = False
   res@tmXTOn                  = False

   res@tmYLLabelDeltaF         = -0.65
   res@tmXBLabelDeltaF         = -0.65

   res@tmYLLabelFontThicknessF = 2
   res@tmXBLabelFontThicknessF = 2

   res@tmYLLabelFontHeightF    = 0.015
   res@tmXBLabelFontHeightF    = 0.015

   res@tmYLLabelStride     = 2

;; lb label bar    
   res@lbLabelBarOn        = False      
   res@lbOrientation       = "Vertical"       
   res@lbLabelAutoStride   = True             
   res@lbBoxSeparatorLinesOn = False

;; mp maps 
   res@mpMinLatF           = -10
   res@mpMaxLatF           = 10
   res@mpMinLonF           = geoinfo(2)
   res@mpMaxLonF           = geoinfo(3)
   res@mpCenterLonF        = 180
;; panel settings
   resP                            = True 
   resP@gsnMaximize                = True      
   resP@gsnPanelLabelBar           = True
   ;resP@lbOrientation       		= "Vertical"
   resP@lbLabelStride       	   = 2                 
   resP@gsnPanelYWhiteSpacePercent = 3.
   resP@gsnPanelXWhiteSpacePercent = 3.
   resP@lbBoxSeparatorLinesOn      = False

   it=ind(time.eq.yyyymmpltStrt)
   do iplt=0,nplt-1                                    
     iyr=floattointeger(time(it)/100.)
     im=time(it)-iyr*100
     print(iyr+" "+im)
     res@gsnRightString      =  "" 
     res@gsnLeftString       = "("+figNotes(iplt)+")"+" "+monthstr(im-1)
     ;symMinMaxPlt(data(it,{-10:10},:), 60, False, res)
     plot(iplt) = gsn_csm_contour_map(wks,data(it,{-10:10},:), res)
     it=it+1   
  end do 
   resP@txString            	   = iyr+" "+longname  
   gsn_panel(wks,plot,(/nplt,1/),resP)
    
end if
print("done")
end
