
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/substring.ncl"
load "$nclfx/zenith.ncl"
load "$nclfx/heatscatter.ncl"
load "$nclfx/attach_labelbar.ncl"
begin
;-------------------------------
;Adding cloud mask has some 
;improvement for 2004
;*******************************
; specification and data put in 
;*******************************  
;DRA: Time difference 8h
;++++ Head +++++
    
    vName    = "LST" 
    Sat      = "GOES"  
    keywrd   = "E";"west";
    version  = "UMD_RTTOV";"UMD_MORTRAN";
    nStd     = 0
   
    St       = "SURFRAD";"ARM";"mesonet";   
    timeStep = "inst_hourly"

    dynt     = "Allday";"day";"night"; 
    year     = "2004-2009"
    NcVar    = "SKT_hr_"+str_lower(dynt)
    facility = ""
   

    UNDEF= -999.0
    nhour= 24
  ;++++++ Plot Parameters  ++++++
    wkstype     = "x11";"pdf";
 
    optOutlier  = True
    capFlag     = True    
    pubFlag     = True
	pltpth  = "~/WORK/LST/"  
    pth	    = "/data/srb3/wchen/Groundtruth/SKT/"
    
    
     StLon = (/-116.018,-88.37,-89.97,-105.10/)
     StLat = (/  36.626, 40.06, 34.25,  48.31/)
     stNames= (/  "dra", "bon", "gwn",  "fpk"/)
     nSt         = dimsizes(StLat)

     date = yyyymmddhh_time(2004,2009,1,"integer")
     ntim  = dimsizes(date)
     yyyy = toint(date/1000000)
     mmddhh = date-yyyy*1000000
     mm   = toint(mmddhh/10000)        
            
    wksname = vName+"_"+St+\
               "_vs_"+Sat+"_"+keywrd+"_"+version 
    if capFlag then 
           capStr = "DJF";"JJA";"SON";"MAM";
          ;capStr = wksname;substring(wksname,9,-1)
           wksname = wksname+"_"+capStr
     else
          capStr = ""
    end if; capFlag  
     if capStr.eq."JJA" then
            capStr = "JUL"
        	figid = "(c) "
        	ylim	= (/260,330/)
        	indss   = ind((mm.eq.7))
        end if
        if capStr.eq."DJF" then
            capStr = "JAN"
        	figid = "(a) "
        	ylim	= (/250,300/)
        	indss   = ind((mm.eq.1))
        end if
       if capStr.eq."MAM" then
        	figid = "(b) "
        	capStr = "APR"
        	ylim	= (/260,320/)
        	indss   = ind((mm.eq.4))
        end if
        if capStr.eq."SON" then 
        	figid = "(d) "
        	capStr = "OCT"        	
        	ylim	= (/260,320/)
        	indss   = ind((mm.eq.10))
        end if   
        wksname = wksname+"_"+capStr        
     ntime = dimsizes(indss)
  	 xx    = new((/nSt,ntime/),"float",UNDEF)
     yy    = new((/nSt,ntime/),"float",UNDEF) 
    do ist = 0,nSt-1
  
     stName = str_upper(stNames(ist))
 
     file1    = "SKT_"+St+"_"+stName+"_"+year+"_"+timeStep+"_"+dynt+".dat"
     stdatain   = fbindirread(pth+file1, 0, ntim, "float")
     stdatain = where(stdatain.gt.0, stdatain,UNDEF)
	 stdatain@_FillValue   = UNDEF
	 stdata = stdatain(indss)
     ;printMinMax(stdata,True)
     file2    = "SKT_"+Sat+"_"+keywrd+"_"+version+"_"+St+"_"+stName+"_"+year+"_"+timeStep+"_"+"Allday.dat"
	 estdatain   = fbindirread(pth+file2, 0, ntim, "float")
     ;estdatain  = where((estdatain.gt.235).and.(estdatain.lt.365),estdatain,UNDEF)
	 estdatain@_FillValue   = UNDEF
	 estdata = estdatain(indss)
     ;printMinMax(estdata,True)    
  
     dof = num(.not.ismissing((estdata-stdata)))
     x   = stdata
     y   = estdata
     x@_FillValue =UNDEF
     y@_FillValue =UNDEF
   
     diff = y-x
  	 Corr = escorc(y,x)
  	 Bias = avg(diff)
  	 N    = num(.not.ismissing(diff))
  	
  	 Std  = stddev(diff)
  	 RMS  = sqrt(avg(diff^2) )  
    
     bias_std = abs(toint(diff/Std))
    ; print(Std)
    ;printMinMax(bias_std,True)

	if optOutlier then
       nStd    = 1
       inds	   = ind(abs(diff).gt.(nStd*Std))

      if .not.all(ismissing(inds)) then
	   x(inds) = UNDEF
	   y(inds) = UNDEF
       diff    = y-x
	   Corr = escorc(y,x);esccr(x,y,0)
  	   Bias = avg(diff)
  	   N    = num(.not.ismissing(diff))
  	   Std  = stddev(diff)
  	   RMS  = sqrt(avg(diff^2) ) 
       delete(inds)	   
  	  end if
    end if
    print("Corr="+Corr+"; Bias="+Bias+"; Std="+Std+"; RMSE="+RMS+"; N="+N+" MeanX="+avg(x))

     x = where(ismissing(y),UNDEF,x)
     y = where(ismissing(x),UNDEF,y)
     ;printMinMax(x,True)
     ;printMinMax(x,True)
     xx(ist,:)=x
     yy(ist,:)=y
     
   end do
   
    	 xlim	=(/0,23/)
         ;ylim	= (/250,330/)
         
          xlabel = "Hour (UTC)"
          ylabel = vName+" (K)"
         
        
       
    
        xx@_FillValue =UNDEF
        yy@_FillValue =UNDEF

        
        tmpx = reshape(xx,(/nSt,ntime/nhour,nhour/))
        x_clim = dim_avg_n_Wrap(tmpx,1)
        tmpy = reshape(yy,(/nSt,ntime/nhour,nhour/))
        y_clim = dim_avg_n_Wrap(tmpy,1)
       ;print(x_clim(3,:)+" ~~  "+y_clim(3,:))
       ;print(tmpx(0,:,15)+" ~~  "+tmpy(0,:,15)+" ~~  "+(tmpy(0,:,15)-tmpx(0,:,15)))
        ;print(tmpx(3,:,21)+" ~~  "+tmpy(3,:,21)+" ~~  "+(tmpy(3,:,21)-tmpx(3,:,21)))
  
        ;printMinMax(x_clim(:,:),True)
        ;printMinMax(y_clim(:,:),True)
        if pubFlag then
        

        end if;
        wks = gsn_open_wks(wkstype,pltpth+"Line_DTR_"+wksname+"_Std"+nStd )
        res = True
        res@gsnDraw            = False        
        res@gsnFrame           = False         
        res@gsnMaximize        = True

        res@tiMainString       = figid+capStr
        res@tiMainFontHeightF  = 0.02
        res@tiMainOffsetYF     = -0.075
        res@trXMinF = xlim(0)
        res@trXMaxF = xlim(1)
        res@trYMinF = ylim(0)
        res@trYMaxF = ylim(1)

        res@tmXBMajorThicknessF     = 4
        res@tmYLMajorThicknessF     = 4
        res@tmXBLabelFontThicknessF = 4
        res@tmYLLabelFontThicknessF = 4

        res@tmXBMode          = "Manual"
        res@tmXBTickSpacingF  = 6

        res@tmBorderThicknessF= 4.0
        res@tmLabelAutoStride = True
        res@tmYROn            = False
        res@tmXTOn            = False
        res@tmYLMinorOn       = False
        res@tmXBMinorOn       = False
        res@tmXBLabelFontHeightF    = 0.0175
        res@tmYLLabelFontHeightF    = 0.0175

       ;res@tmYLLabelDeltaF   = -0.7
       ;res@tmXBLabelDeltaF   = 0.2
        res@tmYLLabelDeltaF   = -0.65
        res@tmXBLabelDeltaF   = -0.6
        
        res@tiYAxisString         = ylabel
        res@tiYAxisOffsetXF       = 0.01
        res@tiYAxisFontThicknessF = 4
        res@tiYAxisFontHeightF    = 0.02
        res@tiXAxisString         = xlabel
        res@tiXAxisOffsetYF       = 0.015
        res@tiXAxisFontThicknessF = 4
        res@tiXAxisFontHeightF    = 0.02

        res@xyDashPattern  = 0 
        res@xyLineThicknessF = 4.
        res@xyLineColors := (/"blue","red","green","purple"/) ; 
        res@xyMarkLineMode = "MarkLines"               
        res@xyMarkers      = (/6,11,9,0/)               
        res@xyMarkerColors := (/"blue","red","green","purple"/)  
        res@xyMarkerThicknessF = 2.5
        res@xyMarkerSizeF     = 0.008 
        if capStr.eq."MAM" then   
        res@pmLegendDisplayMode    = "Always"           
		end if
        res@pmLegendSide           = "Top"               
        res@pmLegendParallelPosF   = .2                 
        res@pmLegendOrthogonalPosF = -0.3            

        res@pmLegendWidthF         = 0.075                
        res@pmLegendHeightF        = 0.14              
        res@lgLabelFontHeightF     = .015  

        res@lgLabelOffsetF         = 0.1  
       ;res@lgLabelJust            ="centerright"            
        res@lgOrientation          = "vertical"
        res@lgPerimOn              = False               
        res@xyExplicitLegendLabels = str_upper(stNames)

        plot = gsn_csm_y(wks,x_clim(:,:),res)
        res@xyDashPattern  = 1 
        plot1 = gsn_csm_y(wks,y_clim(:,:),res)
        overlay(plot,plot1)
        draw(plot)
;**************************************************************
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;**************************************************************
        if capStr.eq."MAM" then   

        lgres                    = True
        lgres@lgLineColors       = (/"black","black"/)    
        lgres@vpWidthF           = 0.25                   
        lgres@vpHeightF          = 0.1 
        lgres@pmLegendWidthF         = 0.075                
       ;lgres@pmLegendHeightF        = 0.14    
        lgres@lgLabelFontHeightF    = .1
        lgres@lgLabelFontThicknessF = 4. 
        lgres@lgLabelOffsetF        = 0.1    
       ;lgres@lgLabelJust        ="centerright"                                      
        lgres@lgPerimOn          = False                    
        lgres@lgDashIndexes      = (/0,1/)              
        lgres@lgLineLabelStrings = (/"",""/)            
        lgres@lgLineThicknessF   = 4.
        gsn_legend_ndc(wks,2,(/"BSRN/SURFRAD","GOES_E"/),0.7,0.3,lgres)
        end if
        frame(wks)
end
    ;StLon = (/-116.018,-88.37,-89.97,-105.10,-105.237,-77.93,-96.62/)
    ;StLat = (/  36.626, 40.06, 34.25,  48.31,  40.125, 40.72, 43.73/)
    ;stNames= (/   "dra", "bon", "gwn",  "fpk",   "tbl", "psu", "sxf"/)
