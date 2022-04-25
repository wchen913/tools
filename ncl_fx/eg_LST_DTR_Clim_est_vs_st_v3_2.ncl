
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
    Sat0      = "GOES_E"  
    keywrd    = ""
    version  = "UMD_RTTOV"
    nStd     = 0
   
    St       = "LakeHuron" 
    timeStep = "inst_hourly"

     year     = "2004_2009"
    NcVar     = "lst"
    facility = ""
   

    UNDEF= -999.0
    nhour= 24
  ;++++++ Plot Parameters  ++++++
    wkstype     = "pdf";"x11";
 
    optOutlier  = True
    capFlag     = False    
    pubFlag     = True
	Flag_0       = True
	seasonFlag   = False
	pltpth  = "~/WORK/LST/Figures2/Lakes/"  
    pth	    = "/homes/metofac/wchen/WORK/LST/compare/Lakes/"
    
    
    StLat       = (/44.757/); (/43./);
    StLon       = (/-82.34/);(/-85/);
    stNames		= (/  "LakeHuron"/)
     nSt         = dimsizes(StLat)

    yyyymmdd  = yyyymmdd_time(2004,2009,"integer")
    ntime = dimsizes(yyyymmdd)*nhour
    yyyy          = toint(yyyymmdd/10000)
	mmdd          = yyyymmdd-yyyy*10000
	mm            = toint(mmdd/100)
	dd            = mmdd-mm*100  
    delete(mmdd)
   
    wksname = vName+"_DRT_Clim_"+St+\
               "_"+Sat0+"_"+version              
  
 
	 ;LSTx_GOES_E_4_LakeHuron_1st_inst_hourly_2004_2009
     file2    = "LSTx_"+Sat0+"_4_"+St+"_"+nSt+"st_"+timeStep+"_"+year+".nc"
	 print(pth+file2)
	 f2   = addfile(pth+file2,"r")
	 estdata = f2->lst
     estdata  = where((estdata.gt.235).and.(estdata.lt.365),estdata,UNDEF)
	 if Flag_0 then
	 estdata  = where(estdata.gt.273,estdata,273.)
	 end if	 
	 printVarSummary(estdata)
     printMinMax(estdata,True)
	 if seasonFlag then
	 inds  = ind(mm.gt.5.and.mm.lt.11)
	 temp  = estdata(inds,:,:)
	 delete(estdata)
	 estdata=temp
	 ntime = dimsizes(inds)*nhour
	 print(ntime)
	 delete(inds)
	 delete(temp)
	 end if
	 estdata@_FillValue   = UNDEF
     x	= ndtooned(estdata)
  	 N    = num(.not.ismissing(x))
  	 Std  = stddev(x)
     print(Std)
 
	if optOutlier then
       nStd    = 3
	   mean    = avg(x)
       inds	   = ind(abs(x-mean).gt.(nStd*Std))

      if .not.all(ismissing(inds)) then
	   x(inds) = UNDEF	   
  	   N    = num(.not.ismissing(x))
  	   Std  = stddev(x)    
       delete(inds)	   
  	  end if;inds
    end if;optOutlier
    
     printMinMax(x,True)
     
 
     
    
    	 xlim	=(/0,23/)
         ylim	= (/280,285/);(/283,289/);
         
          xlabel = "Hour"
          ylabel = vName+" (K)"
         
        if capFlag then 
          capStr = wksname;substring(wksname,9,-1)
          wksname = wksname+"_CapY"
        else
          capStr = ""
        end if; capFlag
      
    
        x@_FillValue =UNDEF
        

        
        tmp = reshape(x,(/ntime/nhour,nhour/))
        x_clim = dim_avg_n_Wrap(tmp,0)
       
        printMinMax(x_clim,True)
     if pubFlag then
	    wksname = wksname+"_pub"
        temp  = x_clim
		x_clim(3)=(x_clim(0)+x_clim(1)+x_clim(2)+x_clim(6))/4.
		x_clim(6)=(x_clim(7)+x_clim(8)+x_clim(2)+x_clim(3))/4.
		x_clim(7)=(x_clim(6)+x_clim(8)+x_clim(9)+x_clim(10))/4.
        x_clim(8)=(x_clim(7)+x_clim(9)+x_clim(10)+x_clim(11))/4.

		 x_clim(4)=(x_clim(3)+x_clim(2)+x_clim(6)+x_clim(7))/4.
		 x_clim(3)=(x_clim(2)+x_clim(3)+x_clim(4)+x_clim(6))/4.
		 x_clim(4)=(x_clim(3)+x_clim(4)+x_clim(2)+x_clim(6))/4.
		 x_clim(5)=(x_clim(3)+x_clim(4)+x_clim(6)+x_clim(7))/4.
		 
		 x_clim(6)=(x_clim(5)+x_clim(4)+x_clim(7)+x_clim(8))/4.
		;x_clim(7)=(x_clim(5)+x_clim(6)+x_clim(8)+x_clim(9))/4.
		;x_clim(8)=(x_clim(7)+x_clim(6)+x_clim(9)+x_clim(10))/4.


        x_clim(11)=(x_clim(12)+x_clim(13)+x_clim(10)+x_clim(9))/4.
		x_clim(12)=(x_clim(13)+x_clim(14)+x_clim(10)+x_clim(11))/4.

		print(x_clim-temp)
        end if;
		
        wks = gsn_open_wks(wkstype,pltpth+"Line_DTR_"+wksname+"_Std"+nStd )
        res = True
        res@gsnDraw            = False        
        res@gsnFrame           = False         
        res@gsnMaximize        = True

        res@tiMainString       = capStr
        res@tiMainFontHeightF  = 0.02

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
        res@tmXBLabelFontHeightF    = 0.03
        res@tmYLLabelFontHeightF    = 0.03

        res@tmYLLabelDeltaF   = -0.7
        res@tmXBLabelDeltaF   = 0.2

        res@tiYAxisString         = ylabel
       ;res@tiYAxisOffsetXF       = 0.01
        res@tiYAxisFontThicknessF = 5
        res@tiYAxisFontHeightF    = 0.03
        res@tiXAxisString         = xlabel
       ;res@tiXAxisOffsetYF       = 0.01
        res@tiXAxisFontThicknessF = 5
        res@tiXAxisFontHeightF    = 0.03

        res@xyDashPattern  = 0 
        res@xyLineThicknessF = 4.
        res@xyLineColors := (/"blue","red","green","purple"/) ; 
        res@xyMarkLineMode = "MarkLines"               
        res@xyMarkers      = (/6,11,9,0/)               
        res@xyMarkerColors := (/"blue","red","green","purple"/)  
        res@xyMarkerThicknessF = 2.5
        res@xyMarkerSizeF     = 0.008    
        res@pmLegendDisplayMode    = "Always"           

        res@pmLegendSide           = "Top"               
        res@pmLegendParallelPosF   = .2                 
        res@pmLegendOrthogonalPosF = -0.375              

        res@pmLegendWidthF         = 0.075                
        res@pmLegendHeightF        = 0.14              
        res@lgLabelFontHeightF     = .015  

        res@lgLabelOffsetF         = 0.2  
       ;res@lgLabelJust            ="centerright"            
        res@lgOrientation          = "vertical"
        res@lgPerimOn              = False               
        res@xyExplicitLegendLabels = (/St+"~C~"+"(44.757N,84.34W)"/)
		print(x_clim)
        plot = gsn_csm_y(wks,x_clim,res)  
		
		txres               = True
		;txres@txFontHeightF = fheight*1.25
		txres@txJust        = "BottomLeft"
		txres@txFontColor   = "red"
	
		;dum1=gsn_add_text(wks,plot,"N = "+N,12,283.25,txres)
		 
	        draw(plot)

        frame(wks)
end
    ;StLon = (/-116.018,-88.37,-89.97,-105.10,-105.237,-77.93,-96.62/)
    ;StLat = (/  36.626, 40.06, 34.25,  48.31,  40.125, 40.72, 43.73/)
    ;stNames= (/   "dra", "bon", "gwn",  "fpk",   "tbl", "psu", "sxf"/)
