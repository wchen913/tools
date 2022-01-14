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
 	yrStrt=1999
 	mmStrt=11
   ;ddStrt= 1
 	yrEnd =2009
 	mmEnd = 10
   ;ddEnd = 31 
 	nplt  = 7
     
 	yyyymmpltStrt = 1
 	yyyymmpltEnd  = 12
 	
 	datatype  = "float"
 	
 	pltdata   = new((/nplt,12/),datatype)
 	pltdata@_FillVaule=-9999
 	latF      = 0
 	lonF      = -110
;=== Path & file names & data type ===
pthin     = "./totlanet/" ;data path
filename1  = pthin+"annualcycle_ssda_199911_200910.dat"
filename2  = pthin+"annualcycle_ssua_199911_200910.dat"
filename3  = pthin+"annualcycle_dslw_199911_200910.dat"
filename4  = pthin+"annualcycle_uslw_199911_200910.dat"  
filename5  = pthin+"annualcycle_lht_199911_200910.dat"
filename6  = pthin+"annualcycle_sht_199911_200910.dat"


;====== Plot Parameters ======
pltpth    = "./"         ;figure pth
wksname   = pltpth+"All_Flux_annualcycle_"+latF+"N"+abs(lonF)+"W";figure name
wkstype   = "eps"        ;figure type

colors    = (/"purple","orange","deeppink2",\
             "blue","black","forestgreen","red1"/) 
patterns  =  (/0,0,0,0,0,0,1/)             
;=== Var Names ===
input_vars   =  "flux"
;=== Flags ===
plotFlag  = True
;=== Parameters ===   
ntime=12
nLat= 180
nLon= 360
;geo information
;geoinfo(0)-geonfo(1):latS-latN
;geoinfo(2)-geoinfo(3):lonW-lonE
geoinfo=(/-89.5,89.5,-179.5,179.5/) 

dimsz= (/ntime,nLat,nLon/)     ;data size
dimNames=(/"time","lat","lon"/);dimetion names
time=ispan(0,11,1); data time stamp
print(dimsizes(time))
 ; data description 
units=" " ;data units
 
;--------------- Put in Data -------------------------

;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if
;==== readin ssda ====
data = new(dimsz,datatype)
longname="monthly mean ssda"
data= fbindirread(filename1,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
ssda     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(ssda)
printMinMax(ssda,True)
delete(data)

;==== readin ssua ====
data = new(dimsz,datatype)
longname="monthly mean ssua"
data = fbindirread(filename2,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
ssua     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(ssua)
printMinMax(ssua,True)
delete(data)

;==== readin dslw ====
data = new(dimsz,datatype)
longname="monthly mean dslw"
data = fbindirread(filename3,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
dslw     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(dslw)
printMinMax(dslw,True)
delete(data)

;==== readin uslw ====
data = new(dimsz,datatype)
longname="monthly mean uslw"
data = fbindirread(filename4,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
uslw     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(uslw)
printMinMax(uslw,True)
delete(data)

;==== readin lh ====
data = new(dimsz,datatype)
longname="monthly mean lh"
data = fbindirread(filename5,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
lh     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(lh)
printMinMax(lh,True)
delete(data)

;==== readin sh ====
data = new(dimsz,datatype)
longname="monthly mean sh"
data = fbindirread(filename6,0,dimsz, datatype)
data = where(data.lt.-900., -9999.,data)
data@_FillValue= -9999.
replace_ieeenan(data,-9999.0,0)
sh     = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(sh)
printMinMax(sh,True)
delete(data)

;==== net radiative flux====
longname="monthly mean net radiative flux"
Rnet = new(dimsz,datatype)
Rnet = (/ssda-ssua+dslw-uslw/)
Rnet@_FillValue = -9999.
Rnet = addmeta(Rnet,dimsz,dimNames,geoinfo,longname,units,time,-1)
printVarSummary(Rnet)
printMinMax(Rnet,True)

;==== net radiative and turbulent flux====
Tnet = new(dimsz,datatype)
longname="monthly mean net radiative and turbulent flux"
Tnet = (/ssda-ssua+dslw-uslw-lh-sh/)
Tnet@_FillValue = -9999.
Tnet = addmeta(Tnet,dimsz,dimNames,geoinfo,longname,units,time,-1)
printMinMax(Tnet,True)
delete(longname)
;==== Setting the data for plot ==== 
 
printVarSummary(ssda(:,{latF},{lonF}))
pltdata(0,:) = ssda(:,{latF},{lonF})
pltdata(1,:) = ssda(:,{latF},{lonF})-ssua(:,{latF},{lonF}) 
pltdata(2,:) = dslw(:,{latF},{lonF})
pltdata(3,:) = dslw(:,{latF},{lonF})-uslw(:,{latF},{lonF})
pltdata(4,:) = -lh(:,{latF},{lonF})
pltdata(5,:) = -sh(:,{latF},{lonF})
pltdata(6,:) = Tnet(:,{latF},{lonF})
pltdata!0    = "flx"
pltdata&flx  = ispan(1,7,1)
flxnm        = (/" SW down "," Net SW "," LW down "," Net LW "," LH "," SH "," Total Net Flux "/)
monsnm       = (/"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"/)
printVarSummary(pltdata)
printMinMax(pltdata,True)
print(dim_avg_n(pltdata,1))
;--------------- Plotting -------------------------
 
if plotFlag then
  delete(pltdata@long_name)
  wks = gsn_open_wks(wkstype,wksname)       

  res                        = True
  res@gsnDraw                = False                   
  res@gsnFrame               = False			 
  
  res@gsnMaximize            = True       
  
  res@tmYROn                  = False
  res@tmYRLabelsOn            = False
  res@tmXTOn                  = False
  res@tmYLMinorOn             = False
  res@tmXBMinorOn             = False
  
    res@tmBorderThicknessF      = 4
    res@tmXBMajorThicknessF     = 4
    res@tmYLMajorThicknessF     = 4
    res@tmXBLabelFontThicknessF = 6
    res@tmYLLabelFontThicknessF = 4
    res@tmXBLabelFontHeightF    = 0.015
    res@tmYLLabelFontHeightF    = 0.02

    res@tmYLLabelDeltaF   = -0.65
    res@tmXBLabelDeltaF   = -0.55

    res@trXMaxF                = 11
    res@trYMinF                = -250
    res@trYMaxF                = 500
    res@tmYLMode               = "Manual"
    res@tmYLTickStartF         = -200
    res@tmYLTickEndF           = 500
    res@tmYLTickSpacingF       = 100
    res@tmXBMode               = "Explicit"
    res@tmXBValues             = time;(0::2)
    res@tmXBLabels             = monsnm;(0::2)
        res@tiYAxisString         = ""

         res@vpXF             = 0.15
         res@vpYF             = 0.85
         res@vpHeightF        = 0.5
         res@vpWidthF         = 0.6
         
         res@xyLineColors          = colors
        res@tiMainString           = "Radiative and turbulent net flux annual cycle at ( "+\
                                        abs(lonF)+"W, "+latF+"N )"
        res@xyDashPatterns         = patterns  
        res@xyLineThicknessF       = 4.5
  ;res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  ;res@xyExplicitLabels       = flxnm
   
 
  plot = gsn_csm_y(wks,pltdata,res)  
  draw(plot)    
  ;***********************************************
; legend resources
;***********************************************

  
   xpos=(/0.22,0.35,0.48,\
          0.22,0.35,0.48,0.61/)      
   ypos=(/0.35, 0.35, 0.35, 0.325, 0.325, 0.325, 0.34/)
   
 
  do ilg = 0,nplt-1
    lgres                    = True
    lgres@lgLineThicknessF   = res@xyLineThicknessF  
    ;lgres@lgItemType         = "Lines"
    lgres@lgPerimOn          = False           
    lgres@lgLabelFontHeightF = .1 
    lgres@lgLabelFontThicknessF = 4
    lgres@vpHeightF          = 0.08            
    lgres@vpWidthF           = 0.125  
    lgres@lgMonoLineColor    = True 
    lgres@lgMonoDashIndex    = True
    lgres@lgDashIndex        = patterns(ilg)
    lgres@lgLineColor        = colors(ilg)
    if ilg.eq.6 then
        lgres@vpHeightF          = 0.08            
        lgres@vpWidthF           = 0.175 
    end if
    if ilg.eq.4.or.ilg.eq.5 then
        lgres@vpHeightF          = 0.08            
        lgres@vpWidthF           = 0.08 
    end if
    gsn_legend_ndc(wks,1,flxnm(ilg),xpos(ilg),ypos(ilg),lgres)
    delete(lgres)
  end do

 
 frame(wks)    ; advance frame
end if
print("done")

