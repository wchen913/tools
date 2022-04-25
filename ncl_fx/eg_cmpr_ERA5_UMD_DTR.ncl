load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/Map_plt_fx.ncl"
load "$nclfx/Hist_plt_fx.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters 
yrstrt = 2004
yrend = 2009
pth = "/data/srb4/wchen/ERA5/"
sat = "era5";"MOD11C1";
vName = "T2m"
ncVarName = "DTR";"Tmax";"Tmin"; "Tmax";
region = "US"
opt = "water"
version = "v1"
;+++ Flags
optplt = False
landmask = True
watermask = False
PltMapF = True
PltHistF = True
;+++ Parameters	    
nLat = 101
nLon = 221

geoinfo = (/25,50,-125.,-70/)
dimsz	= (/nLat,nLon/)
dimNames = (/"lat","lon"/)
datatype = "float"
units	= "(K)"
nrec	= 0
UNDEF = -999.
	 
longname =  str_upper(sat)+" "+ncVarName+" (UMD)" 
monstr = (/"JAN","FEB","MAR","APR","MAY","JUN",\
                    "JUL","AUG","SEP","OCT","NOV","DEC"/)
;+++ Time Coverage
yyyymmdd = yyyymmdd_time(yrstrt,yrend,"integer")
yyyy = toint(yyyymmdd/10000)
mmdd = yyyymmdd-yyyy*10000
mm = toint(mmdd/100)
dd = mmdd-mm*100
ntime = dimsizes(yyyymmdd)
delete(mmdd)
;+++ input data
print("data ERA5")
;print(yyyy(0)+" "+mm(0)+" "+dd(0)+" "+hh(23))
infname = vName+".x.era5.025x025.daily.maxmin."+yrstrt+"."+yrend+"."+region+".nc"
;infname = vName+".x.era5.025x025.daily.maxmin."+yrstrt+".2019."+region+".nc"
print(pth+infname)			
fid = addfile(pth+infname,"r")
datain := fid->$ncVarName$
datain = addmeta(datain,dimsizes(datain),(/"time","lat","lon"/),(/25,50,-125,-70/),""," ",yyyymmdd,-1)                
datain@_FillValue = UNDEF 
printVarSummary(datain)
printMinMax(datain,True)
print(stddev(datain))
era5=datain
delete(datain)
print("data UMD")
; GOES_E_LST_DTR_2004-2009.0.25x0.25.nc
sat = "GOES_E";"MOD11C1";
vName = "LST"
GridType = "0.25x0.25"
infname = sat+"_"+vName+"_"+ncVarName+"_"+yrstrt+"-"+yrend+"."+GridType+".nc"
print(pth+infname)			
fid = addfile(infname,"r")
ncVarName = ncVarName+"_025"
datain := fid->$ncVarName$
datain = addmeta(datain,dimsizes(datain),(/"time","lat","lon"/),(/25,50,-125,-70/),""," ",yyyymmdd,-1)                
datain@_FillValue      = UNDEF 
printVarSummary(datain)
printMinMax(datain,True)
print(stddev(datain))
umd = datain
if optplt then
		wks = gsn_open_wks("x11", "test")
		gsn_define_colormap(wks,"BlGrYeOrReVi200") 
		res := True
		res@gsnMaximize = True
		res@gsnAddCyclic = False
		res@gsnSpreadColors = True
		res@cnFillOn = True
		res@cnFillMode = "CellFill";"RasterFill"
		res@cnLinesOn = False
		res@cnInfoLabelOn = False
		res@cnLineLabelsOn = False
		res@mpMinLatF = 25
		res@mpMaxLatF = 50
		res@mpMinLonF = -125
		res@mpMaxLonF = -70
		res@mpOutlineBoundarySets = "USStates";"AllBoundaries";
		res@cnFillDrawOrder = "PreDraw"
		res@mpFillAreaSpecifiers = (/"Land", "Water"/)
		res@mpSpecifiedFillColors = (/"transparent","white"/)
		;res@mpDataBaseVersion = "Ncarg4_1"
		;res@mpOceanFillColor =   "white"
		;res@mpInlandWaterFillColor = "white"
		;res@mpLandFillColor = "transparent"
		plot=gsn_csm_contour_map(wks,era5(100,:,:),res)
end if
				
;---- Processing

 ;do mon=7,7;1,12

mon   = 1 ;1;13;
if mon.le.12 then
		inds = ind(mm.eq.mon)
		era5_ssaw =  era5(inds,:,:)
		umd_ssaw = umd(inds,:,:)		   
		tstr      = monstr(mon-1)	
		diff = umd_ssaw-era5_ssaw	     
		delete(inds)
else
	  diff = umd-era5
	  tstr = "Annual"		 
end if 
data = diff
data = smth9(diff,0.5,-0.25,False)
printMinMax(data,True)       
data_clim = dim_avg_n_Wrap(data,0)
data_clim = (/smth9(data_clim,0.5,-0.25,False)/)
printMinMax(data_clim,True)       

;******************************************************
;						 Plotting
;******************************************************	
;+++ MAP
	
pltpth =  "~/WORK/LST/Figures3/";
wkstype = "x11";"pdf";"eps"; 
wksname = ncVarName+"_diff_umd_vs_era5_"+\
      					yrstrt+"-"+yrend+"_"+sprinti("%0.2i", mon)+"_"+version+"."+GridType
lftstr    = ncVarName
rtstr     = ""
tistr     = ""
if isStrSubset(ncVarName,"DTR") then
	  if mon.eq.1 then
				clim = (/-5,15,1,5/)
				hists = (/-10,20,16,1/)
				YMinF = 0;0.1*10000000
				figid = ""
		end if
		if mon.eq.7 then
				clim = (/-35,35,1,5/)
				hists = (/-40,40,9,1/)
				YMinF = 0;0.1*10000000
				figid = ""
		end if
end if;ncVarName


print("=============Map Plotting============")
if PltMapF then

    wks = gsn_open_wks(wkstype, pltpth+"maps_"+wksname)
    ;gsn_define_colormap(wks,"MPL_autumn")
		;gsn_reverse_colormap(wks)
		gsn_define_colormap(wks,"GMT_seis")
		gsn_reverse_colormap(wks)
    ;gsn_define_colormap(wks,"MPL_jet")
    res = True
   	res@gsnFrame = False
    res@gsnDraw = False
   	res@gsnMaximize = True              
   	res@gsnAddCyclic = False           
   	res@gsnSpreadColors = True 
        
		res@cnFillOn = True            
		res@cnFillMode = "CellFill";  "RasterFill";     
		res@cnLinesOn = False            
		res@cnInfoLabelOn = False
		res@cnLineLabelsOn = False
		res@cnSmoothingOn = True
		;res@cnSmoothingTensionF = -3.0 ;default:-2.5
		res@cnSmoothingDistanceF = 0.05 ;default:0.01;
		res@cnRasterSmoothingOn = True
		res@cnRasterSampleFactorF = 2.
		res@lbLabelBarOn = True
		res@lbBoxLinesOn = False            
		res@lbBoxSeparatorLinesOn = False
		res@lbLabelStride = clim(3)
		;res@lbOrientation = "Vertical"
		res@pmLabelBarOrthogonalPosF = 0.08
        
		res@lbTitleOn =  True               
		res@lbTitleString    			= units                
		res@lbTitlePosition  			= "Right"             
		res@lbTitleFontHeightF			= 0.0175  
		res@lbTitleFontThicknessF 		= 2              
		res@lbTitleDirection 			= "Across" 
		res@lbTitleOffsetF				= -0.0025;-0.01
		
		res@mpMinLatF             = 25
		res@mpMaxLatF             = 50
		res@mpMinLonF             = -125
		res@mpMaxLonF             = -70
   		   		
		res@tmXBMajorThicknessF     = 3
		res@tmYLMajorThicknessF     = 3
		res@tmBorderThicknessF      = 3
		res@mpGeophysicalLineThicknessF = 2

		res@tmXBLabelFontThicknessF = 5
		res@tmYLLabelFontThicknessF = 5 
		res@tmYLLabelFontHeightF	= 0.0175
		res@tmXBLabelFontHeightF	= 0.0175
		
		res@tmYLLabelDeltaF = -0.725
		res@tmXBLabelDeltaF = -0.825
	
		res@tmYLMinorOn = False
		res@tmYROn = False
		res@tmXBMinorOn = False
		res@tmXTOn = False
		XBValues = (/-120,-110,-100,-90,-80,-70/)
		XBLabels = (/"120~F34~0~F~W", "110~F34~0~F~W","100~F34~0~F~W",\
       					 "90~F34~0~F~W","80~F34~0~F~W","70~F34~0~F~W"/)
   		
		YLValues = (/25,30,35,40,45,50/)
		YLLabels = (/"25~F34~0~F~N","30~F34~0~F~N","35~F34~0~F~N",\
									"40~F34~0~F~N","45~F34~0~F~N","50~F34~0~F~N"/)
		res@tmXBMode   = "Explicit"
		res@tmXBValues = XBValues
		res@tmXBLabels = XBLabels
		res@tmYLMode   = "Explicit"
		res@tmYLValues = YLValues
		res@tmYLLabels = YLLabels
 	    
		;res@gsnCenterStringFontHeightF = 0.0175
		;res@gsnLeftStringFontHeightF   = 0.0175
		;res@gsnRightStringFontHeightF  = 0.0175

		;res@gsnCenterStringOrthogonalPosF = -0.04
		;res@gsnLeftStringOrthogonalPosF = -0.04
		;res@gsnRightStringOrthogonalPosF = -0.04
 		;res@mpDataBaseVersion           = "MediumRes"
		;turn on boundaries; " USStates" ; "National"; "AllBoundaries" ;
   	;res@mpOutlineBoundarySets = " USStates" ;  
   		
		res@cnFillDrawOrder       = "PreDraw"
		res@mpFillAreaSpecifiers  = (/"Land", "Water"/)
		res@mpSpecifiedFillColors = (/"transparent","white"/)
		;res@mpDataBaseVersion     = "Ncarg4_1"
		res@mpOceanFillColor      =   "white"
		res@mpInlandWaterFillColor= "white"
		res@mpLandFillColor       = "transparent"
	 	res@cnLevelSelectionMode = "ManualLevels"
		res@cnLevelSpacingF      = clim(2)
		res@cnMinLevelValF       = clim(0)
		res@cnMaxLevelValF       = clim(1)
		plot=gsn_csm_contour_map_ce(wks,data_clim,res)
      
		getvalues plot
				"tmYLLabelFontHeightF"   : fheight
		end getvalues

    txres               = True
    txres@txFontHeightF = fheight*1.25
    txres@txJust        = "BottomLeft"
    txres@txFontColor   = "red"
    dum1=gsn_add_text(wks,plot,tstr,-122.5,27.25,txres)
    txres@txFontColor   = "Blue"
    dum2=gsn_add_text(wks,plot,ncVarName,-75,27.25,txres)
    txres@txFontColor   = "Black"
    dum3=gsn_add_text(wks,plot,figid,-90,27.25,txres)
    draw(plot)
    frame(wks)
    delete(res)
end if ;PltMapF
   print("=============Histogram Plotting============")
if PltHistF then
	 	if opt.eq."land" .or. opt.eq."water" then
				lsm = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat",0,(/501,1101/), "integer")
				lsm = addmeta(lsm,(/501,1101/),(/"lat","lon"/),(/25,50,-125,-70/),"land sea mask"," ",-1,-1)
				; printVarSummary(lsm(::5,::5))
				; exit
				lsmsk = conform_dims(dimsizes(data),lsm(::5,::5),(/1,2/))
				copy_VarMeta(data,lsmsk)
				if opt.eq."land" then
						data_clim = mask(data_clim,lsm(::5,::5).eq.0,False)
						data = mask(data,lsmsk.eq.0,False)
				else
						data_clim = mask(data_clim,lsm(::5,::5).eq.1,False)
						data = mask(data,lsmsk.eq.1,False)
				end if              
		end if;opt
		res = True
		res@gsnFrame = False
		res@gsnDraw = False			
		res@gsnMaximize = True 
		res@gsnHistogramBarWidthPercent = 100
		res@gsnHistogramMinMaxBinsOn = False
		res@gsnHistogramBarColors = "blue" 
		if isdefined("YMinF") then
				res@trYMinF = YMinF
		end if
		if isdefined("YMaxF") then
				res@trYMaxF = YMaxF
		end if
		res@tmXBMajorLengthF = 0.01
		res@tmYROn = False       
		res@tmYLMinorOn = False
		res@tmXTOn = False 
		res@tmXBLabelStride = hists(3)
		res@tmYLLabelDeltaF = -0.65
		res@tmXBLabelDeltaF = -0.55
		;res@tmYLLabelStride = 2
		res@tmXBLabelFontHeightF = 0.025
		res@tmYLLabelFontHeightF = 0.025
		res@tmYLLabelFontThicknessF = 3.5
		res@tmXBLabelFontThicknessF = 3.5
		res@tmYLFormat =  "0@!;*^se"
		res@tiXAxisString = "Temperature"
		res@tiYAxisOffsetXF = 0.005
		res@tiXAxisOffsetYF = 0.005
		res@tiXAxisFontHeightF = 0.0275
		res@tiYAxisFontHeightF = 0.0275
		res@tiXAxisFontThicknessF = 3.5
		res@tiYAxisFontThicknessF = 3.5
		res@gsnHistogramClassIntervals = fspan(hists(0),hists(1),hists(2))	
		wks = gsn_open_wks(wkstype, pltpth+"hists_"+wksname)
		plot = gsn_histogram(wks,ndtooned(data),res)
		getvalues plot
				"tmYLLabelFontHeightF"   : fheight
				"tmXBValues"			 : tmXBValues
				"tmYLValues"			 : tmYLValues
		end getvalues
		nxb = dimsizes(tmXBValues)
		nyl = dimsizes(tmYLValues)
		txres = True
		txres@txFontHeightF = fheight*0.85
		txres@txJust = "BottomLeft"
		txres@txFontColor = "Black"
		dum1=gsn_add_text(wks,plot,tstr+"~C~"+ncVarName,0.5*(tmXBValues(0)+tmXBValues(1)),\
		0.5*(tmYLValues(nyl-2)+tmYLValues(nyl-1)),txres)
		txres@txFontColor   = "Black"
		dum2=gsn_add_text(wks,plot,figid,0.5*(tmXBValues(nxb-2)+tmXBValues(nxb-3)),\
		0.5*(tmYLValues(nyl-2)+tmYLValues(nyl-1)),txres)
		draw(plot)
		frame(wks)
end if ;PltHistF
;end do ; mon  
print("done")
end

;tmp   = dataAvg(hour,:,:)
;delete(dataAvg)
;tmp  = data(day,hour,:,:) 
;tmp  = addmeta(tmp,dimsz(2:3),dimNames(2:3),geoinfo,longname,units,-1,-1)
;day  = 12  
;hour = 17 
;nrec = (day-1)*nhour+hour

 