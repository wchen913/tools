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
;*******************************
; specification and data put in 
;*******************************  

;++++ Head +++++
    vName    = "ssda" 
    Sat      = "DX";"MODIS"; 
    version  = "v3.4";"new";"old";"RmBias";

    St       = "TWP";"TAO";
    timeStep  = "mon";"day";

    if timeStep.eq."mon"
         timestep  = "mon"
		 ymdStrt   = toint(20020701)
		 ymdEnd    = toint(20091231)
         if St.eq."TAO" then
		    nSt       = 17
         else if St.eq."TWP" then
            nSt       = 3
         end if
         end if
    else if timeStep.eq."day" then 
        timestep  = "dy";"mon";
   		ymdStrt   = toint(20060101)
   		ymdEnd    = toint(20091231)
        if St.eq."TAO" then
    	   nSt      = 2      
   		else if St.eq."TWP" then
           nSt      = 3
         end if
         end if
   end if
   end if
   pth	= "/data/crash/wchen/merge_cut_data/"

   file2= vName+"_"+Sat+version+"_4_"+St+"_"+nSt+"st"+"_"+\
		  timeStep+"_"+ymdStrt+"_"+ymdEnd+".nc" 
   file1 = vName+"_"+St+"_"+nSt+"st_"+\
		   timestep+"_"+ymdStrt+"_"+ymdEnd+".nc"

	scatterFlag = True
    

    if scatterFlag then
        stdline     = False
    	bestfitline = True
		optOutlier = True

	    pltpth  = "~/tmp/"
		wkstype = "eps"
		wksname = "xscatter"+"_"+vName+"_"+St+"_vs_"+Sat+version+"_"+\
				  nSt+"st"+"_"+timeStep+"_"+ymdStrt+"_"+ymdEnd
		if optOutlier then
			wksname = wksname+"outlierY"
		end if
    	 xlim	= (/0,500/)
         ylim	= xlim
        
         xlabel = "Observed"
         ylabel = "Estimated"
         
         capStr = Sat+version+". "+St+" : "+nSt+" Sites. "+\
				  "Time Res: "+timeStep+". Period: "+ymdStrt+" - "+ymdEnd	
         
    end if

;++++ Read Ground truth ++++ 
    print("Read Data")  
    fid		= 	addfile(pth+file1,"r")
       
	data1	= fid->$vName$
    data1   = (/tofloat(data1)/)
    data1@_FillValue = 1e+35
    ;printVarSummary(data)
    TIME	= fid->time
    x		= ndtooned(data1)
        
    lonst       = fid->lonst
    latst       = fid->latst
	delete(fid)

	
;++++ Read Estimated Data ++++   
	fid		= 	addfile(pth+file2,"r")
    data2	= fid->$vName$
    data2   = (/tofloat(data2)/)
	data2@_FillValue = -9999.
    y		= ndtooned(data2)


;************************************************
; plotting 
;************************************************
 if scatterFlag then
	
    diff = y-x
  	Corr = esccr(x,y,0)
  	Bias = avg(diff)
  	N    = num(.not.ismissing(diff))
  	Std  = stddev(diff)
  	RMS  =  sqrt(avg(diff^2) ) 

	if optOutlier then
	   dof	   = N
       inds	   = ind(abs(diff).gt.(3*Std))
	   x(inds) = x@_FillValue
	   y(inds) = y@_FillValue
       diff    = y-x
	   Corr = esccr(x,y,0)
  	   Bias = avg(diff)
  	   N    = num(.not.ismissing(diff))
  	   Std  = stddev(diff)
  	   RMS  =  sqrt(avg(diff^2) ) 
    end if
    ;+++ Best fit
	rc		= regline(x,y)
    z       = rc*(x-rc@xave)+rc@yave
    ;printVarSummary(z)
	
  	textstr = (/"Corr = "+sprintf("%.2f",Corr),\
			  "Bias = "+sprintf("%.2f",Bias)+" ( "+sprintf("%.1f",abs(Bias/avg(x))*100)+"% )",\
			  "RMS = "+sprintf("%.2f",RMS)+" ( "+sprintf("%.1f",abs(RMS/avg(x))*100)+"% )",\
			  "N = "+N,\
			  "Std = "+sprintf("%.2f",Std)+" ( "+sprintf("%.1f",abs(Std/avg(x))*100)+"% )"/) 
	print(textstr)
 	wks   = gsn_open_wks (wkstype,pltpth+wksname)            ; open workstation

 	res                   = True
 	res@gsnDraw   		  = False                             ; don't draw yet
  	res@gsnFrame  		  = False 
	res@gsnMaximize 	  = True

   
    ;res@vpXF             = 0.15                
 	;res@vpYF             = 0.8                
 	;res@vpHeightF        = 0.5                
 	;res@vpWidthF         = 0.65 
    
                     
 	res@tiMainString      = capStr
    res@tiMainFontHeightF = 0.02 
    res@tiMainOffsetYF	  = 0.05
      
 	res@xyMarkLineModes   = "Markers"                ; choose which have markers
 	res@xyMarkers         =  16;NhlNewMarker(wks,"u",34,0.0,0.0,1.3125,1.5,0.0); filled triangle
 	res@xyMarkerColor     = "blue"                    ; Marker color
 	res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)
    
	res@trXMinF	= xlim(0)
    res@trXMaxF	= xlim(1)
    res@trYMinF	= ylim(0)
    res@trYMaxF = ylim(1)


    res@tmBorderThicknessF= 4.0
 	res@tmLabelAutoStride = True                     ; nice tick mark labels
 	res@tmYROn            = False
 	res@tmXTOn            = False
 	res@tmYLMinorOn       = False
 	res@tmXBMinorOn       = False

    res@tmXBMajorThicknessF     = 4
    res@tmYLMajorThicknessF  	= 4  
    res@tmXBLabelFontThicknessF = 4
    res@tmYLLabelFontThicknessF = 4
    res@tmXBLabelFontHeightF    = 0.03
    res@tmYLLabelFontHeightF    = 0.03

    res@tmYLLabelDeltaF   = -0.65
    res@tmXBLabelDeltaF   = -0.55

	res@tiYAxisString         = ylabel
   ;res@tiYAxisOffsetXF       = 0.01
   	res@tiYAxisFontThicknessF = 5
    res@tiYAxisFontHeightF    = 0.03

   	res@tiXAxisString         = xlabel
   ;res@tiXAxisOffsetYF       = 0.01
   	res@tiXAxisFontThicknessF = 5
    res@tiXAxisFontHeightF    = 0.03
 	plot  = gsn_csm_xy (wks,x,y,res) ; create plot
      
	respl	= True   
    respl@gsLineDashPattern	= 16
    respl@gsLineColor       = "black"
    respl@gsLineThicknessF  = 5.
    plotpl1 = gsn_add_polyline  (wks, plot, xlim, ylim, respl)
    if stdline then
		respl@gsLineColor       = "red"  
    	plotpl2 = gsn_add_polyline  (wks, plot, (/xlim(0)+Std,xlim(1)/), (/ylim(0),ylim(1)-Std/), respl)
    	plotpl3 = gsn_add_polyline  (wks, plot, (/xlim(0),xlim(1)-Std/), (/ylim(0)+Std,ylim(1)/), respl)
	end if
	

    getvalues plot
    "tmXBValues"             : tmXBValues  
    "tmYLValues"             : tmYLValues
    ;"tmYLLabelFontHeightF"   : fonthight
    end getvalues
   ;print(fonthight)
    ntym = dimsizes(tmYLValues)
    ntxm = dimsizes(tmXBValues)

	 txres               = True
     txres@txFontHeightF = 0.03;fonthight
     txres@txJust        = "BottomLeft"
   dum1=gsn_add_text(wks,plot,textstr(0),0.03*tmXBValues(ntxm-1),0.92*tmYLValues(ntym-1),txres)
   dum2=gsn_add_text(wks,plot,textstr(1),0.03*tmXBValues(ntxm-1),0.85*tmYLValues(ntym-1),txres)
   dum3=gsn_add_text(wks,plot,textstr(2),0.03*tmXBValues(ntxm-1),0.78*tmYLValues(ntym-1),txres)
   dum4=gsn_add_text(wks,plot,textstr(4),0.03*tmXBValues(ntxm-1),0.71*tmYLValues(ntym-1),txres)
   dum5=gsn_add_text(wks,plot,textstr(3),0.03*tmXBValues(ntxm-1),0.64*tmYLValues(ntym-1),txres)

   
    ;txres@txFontHeightF = 0.015
    ;gsn_text_ndc(wks,capStr,0.3,0.025,txres) 
     	if bestfitline then
       res@xyMarkLineModes   = "Lines"
       res@xyLineThicknesses = 5.
	   res@xyLineColor       = "red"
       plotl2  = gsn_csm_xy (wks,x,z,res)
		overlay(plot,plotl2)
    end if
    draw(plot)
 end if

end
;if scatterFlag then
;	   capStr2=""	
;	   do iSt = 0,nSt-1
;	   	if lonst(iSt).ge.0 then
;       	lonnote = "E"
;		else
;			lonnote = "W"
;		end if
;       if latst(iSt).ge.0 then
;        	latnote = "N"
;		else
;			latnote = "S"
;		end if
;       capStr2	= capStr2+abs(latst(iSt))+latnote+abs(lonst(iSt))+lonnote+"; "
;       end do
;      capStr1	= "Period: "+ymdStrt+" - "+ymdEnd+". "+St+" Site: "				  
;	end if
    ;print("Bias: "+Bias+" Std: "+Std+" RMS: "+RMS+" N: "+N)
    ;res@vpXF             = 0.12                
 	;res@vpYF             = 0.85                
 	;res@vpHeightF        = 0.4                
 	;res@vpWidthF         = 0.75    
	;print(fid) 
    ;indvar    = str_match_ind_ic(VarNames,VarName)
