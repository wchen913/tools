;***************************************** 
;	This script is for Histogram Plotting
;*****************************************
undef("Hist_plt_value") 
procedure Hist_plt_value(data[*]:numeric,limts[4]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors[1]:string\
                    ,tiXstr[*]:string\
                    ,opt)
local res,plot,npct,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,stats,\
      statstr,txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4
begin
        npct = limts(3)
        pct1 = limts@pct1
    
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		res@gsnHistogramBarColors       = "blue"
        res@gsnHistogramClassIntervals  = fspan(limts(0),limts(1),limts(2))

  		res@tmXBMajorLengthF           = 0.01
		;res@tmXBLabelStride             = 2
        res@gsnHistogramMinMaxBinsOn   = False
		
		res@tmYLLabelJust				= "CenterRight"
  		res@tmXBMajorLengthF            = 0.0125
		res@tmYLMajorLengthF            = 0.0125
		res@tmXBMajorThicknessF         = 2.75*2
		res@tmYLMajorThicknessF         = 2.75*2
		res@tmBorderThicknessF			= 2.75*2
		;res@tmYLMajorOutwardLengthF   = -0.021 						
		res@tmYLLabelDeltaF 			= -0.8
		res@tmXBLabelDeltaF 			= -0.75

        res@tiXAxisString               = tiXstr(0)       
        res@tiYAxisOffsetXF             = 0.005
        res@tiXAxisOffsetYF             = 0.005
		   
        res@tiYAxisOffsetXF             = 0.0125
        
  		 tmYLLabels  = ispan(0,npct,1)
         tmYLValues  = tmYLLabels*pct1


        wks = gsn_open_wks(pltType, pltDir+pltName)
        gsn_define_colormap(wks,colors)

  		plot=gsn_histogram(wks,data,res)
		getvalues plot
            "tmXBLabels"             : tmXBLabels
            "tmXBValues"             : tmXBValues
			
            "tmYLLabelFontHeightF"   : fheight
			"tmYLLabelFontThicknessF": fthick
        end getvalues

            nxm  = dimsizes(tmXBValues)
			xint = toint(nxm/6)
			nxm = dimsizes(tmXBValues(::xint))			
			if nxm.gt.10 then
				xint = toint(xint*2)
			end if
			
			 nym  = dimsizes(tmYLValues)
			 yint = toint(nym/6)
			 nym = dimsizes(tmYLValues(::yint))			
			if nym.gt.10 then
				yxint = toint(yint*2)
			end if
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues(::xint)
                         "tmXBLabels":   tmXBLabels(::xint)

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues(::yint)
                         "tmYLLabels":   tmYLLabels(::yint)

                         "tmYROn"           :   False
                         ;"tiYAxisString"    : "Percent"
						  "tmYLLabelFontHeightF"   : fheight*1.1
						 "tmXBLabelFontHeightF"   : fheight*1.075
						 "tmYLLabelFontThicknessF": fthick*1.3*2
						 "tmXBLabelFontThicknessF": fthick*1.3*2
						 "tiXAxisFontHeightF"     : fheight*1.3
						 "tiXAxisFontThicknessF"  : fthick*1.3*2
						 "tiYAxisFontHeightF"     : fheight*1.3
						 "tiYAxisFontThicknessF"  : fthick*1.3*2

        end setvalues
		
		
		
		
        stats=stat_dispersion(data,False)
        statstr = (/"Mean: "+sprintf("%.2f",stats(0)),\
                    "Median: "+sprintf("%.2f",stats(8)),\
                    "Min: "+ sprintf("%.2f",stats(2)),\
                    "Max: "+sprintf("%.2f",stats(14))/)
       
            txtres               = True
            txtres@txFontHeightF = fheight
            txtres@txJust        = "BottomLeft"
            txtres@txFontThicknessF = 	fthick*2
           
            xptxt= tofloat(tmXBValues(::xint))
			
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)
			

            ;yp              = (yptxt(nym-1)+yptxt(nym-2))/2.
			yp              = yptxt(nym-1)
			gsn_text_ndc(wks,"(x10~S~"+log10(pct1)+"~N~)",0.09,0.87,txtres) 
			
	txtres@txFontHeightF = fheight*1.1	
    txtres@txJust        = "TopRight"
	txtres@txFontColor   = "red"
    xp              = xptxt(nxm-1)-(abs(xptxt(1)-xptxt(0)))/5.
	dum0   = gsn_add_text(wks,plot,tiXstr(1),xp,0.875*yp,txtres)
if opt.ne.0 then			
    txtres@txJust        = "BottomLeft"
	txtres@txFontColor   = "black"
    xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/6.

    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.925*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.845*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.765*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.685*yp,txtres)
    end if
		draw(plot)
		frame(wks)
  		
 
end

undef("Hist_plt_diff_temp") 
procedure Hist_plt_diff_temp(data[*]:numeric,npct:numeric\
                        ,statstr[*]:string\
                        ,pltType[1]:string, pltDir[1]:string\
                        ,pltName[1]:string\
                        ,tiXstr[*]:string\
                        ,opt)
local res,plot,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,\
      txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4,dum5,cmap
begin
   
    
    pct1=npct@pct1
    cmap = read_colormap_file("WhBlReWh")
 printVarSummary(cmap)
   
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
		res@gsnHistogramMinMaxBinsOn    = True
        res@gsnHistogramClassIntervals  = fspan(-20,20,41)

        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		res@gsnHistogramBarColors       = cmap(29:72,:) 
		
  		res@tmYLLabelJust				= "CenterRight"
  		res@tmXBMajorLengthF            = 0.01
		res@tmYLMajorLengthF            = 0.01
		res@tmXBMajorThicknessF         = 2.75*2
		res@tmYLMajorThicknessF         = 2.75*2
		res@tmBorderThicknessF			= 2.75*2
		;res@tmYLMajorOutwardLengthF   = -0.021 						
		res@tmYLLabelDeltaF 			= -0.85
		res@tmXBLabelDeltaF 			= -0.85

        res@tiXAxisString               = tiXstr(0)      
        res@tiYAxisOffsetXF             = 0.005
        res@tiXAxisOffsetYF             = 0.005
		   
        res@tiYAxisOffsetXF             = 0.0125
        
		 tmYLLabels  = ispan(0,npct,1)
         tmYLValues  = tmYLLabels*pct1


        wks = gsn_open_wks(pltType, pltDir+pltName)
       ;gsn_define_colormap(wks,"WhBlReWh")

        
  		plot=gsn_histogram(wks,data,res)

  		tmXBValues    = plot@EndBarLocs(::5)
        tmXBLabels    = ispan(-20,20,5)
         nym  = dimsizes(tmYLValues)
			 yint = toint(nym/6)
			 nym = dimsizes(tmYLValues(::yint))			
			if nym.gt.10 then
				yxint = toint(yint*2)
			end if
		getvalues plot            
            "tmYLLabelFontHeightF"   : fheight
			"tmYLLabelFontThicknessF"   : fthick
 
        end getvalues
	  
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues
                         "tmXBLabels":   tmXBLabels

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues(::yint)
                         "tmYLLabels":   tmYLLabels(::yint)
						
                         "tmYROn"           :   False
                        ;"tiYAxisString"    :   "Percent"
						 "tmYLLabelFontHeightF"   : fheight*1.1
						 "tmXBLabelFontHeightF"   : fheight*1.1
						 "tmYLLabelFontThicknessF": fthick*1.3*2
						 "tmXBLabelFontThicknessF": fthick*1.3*2
						 "tiXAxisFontHeightF"     : fheight*1.3
						 "tiXAxisFontThicknessF"  : fthick*1.3*2
						 "tiYAxisFontHeightF"     : fheight*1.3
						 "tiYAxisFontThicknessF"  : fthick*1.3*2
        end setvalues
       
       
            txtres               = True
            txtres@txFontHeightF = fheight
            txtres@txJust        = "BottomLeft"
            txtres@txFontThicknessF = 	fthick*2

            xptxt= tofloat(tmXBValues)
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)

           ;yp              = (yptxt(nym-1)+yptxt(nym-2))/2.
			yp              = yptxt(nym-1)
			gsn_text_ndc(wks,"(x10~S~"+log10(pct1)+"~N~)",0.09,0.87,txtres) 
			
 if opt.ne.0 then
	txtres@txJust        = "CenterCenter"
	txtres@txFontColor   = "red"
    xp              =(abs(xptxt(nxm-1)-xptxt(0)))/2.
	dum0   = gsn_add_text(wks,plot,tiXstr(1),xp,0.925*yp,txtres)
    txtres@txFontHeightF = fheight
    txtres@txJust = "BottomLeft"
	txtres@txFontColor   = "black"
	xp   = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/10.
    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.925*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.845*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.765*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.685*yp,txtres)
    dum5 = gsn_add_text(wks,plot,statstr(4),xp,0.605*yp,txtres)

end if
		draw(plot)
		frame(wks)
  		
 
end
  
undef("Hist_plt_value_complicate") 
procedure Hist_plt_value_complicate(data[*]:numeric,limts[4]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors[1]:string\
                    ,tiXstr[1]:string\
                    ,opt:logical)
local res,plot,npct,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,stats,\
      statstr,txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4,opt
begin
   
    npct = limts(3)
    pct1=dimsizes(data)/100.
    if opt.and.isatt(opt,"YMinF") then
		YMinPct   = opt@YMinF
	else
		YMinPct   = 0
	end if
	
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		 
  		res@tmXBMajorLengthF           = 0.01
		;res@tmXBLabelStride             = 2

        res@gsnHistogramMinMaxBinsOn   = False
        res@tiXAxisString              = tiXstr
        res@gsnHistogramBarColors       = "blue"
			
        res@tiYAxisOffsetXF            = 0.005
        res@tiXAxisOffsetYF            = 0.005
        res@gsnHistogramClassIntervals = fspan(limts(0),limts(1),limts(2))
        res@trYMinF = YMinPct*pct1

  		tmYLLabels  = ispan(YMinPct,npct,1)
        tmYLValues  = tmYLLabels*pct1

        wks = gsn_open_wks(pltType, pltDir+pltName)
        gsn_define_colormap(wks,colors)

  		plot=gsn_histogram(wks,data,res)
		getvalues plot
            "tmXBLabels"             : tmXBLabels
            "tmXBValues"             : tmXBValues
            "tmYLLabelFontHeightF"   : fheight
        end getvalues
            nxm  = dimsizes(tmXBValues)
			xint = toint(nxm/6)
			nxm  = dimsizes(tmXBValues(::xint))
			yint = 1
			if nxm.gt.10 then
				xint = toint(xint*2)
			end if
			 nym = dimsizes(tmYLValues)
			 if nym.gt.5 then
				yint = toint(yint*(nym/5))
			end if
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues(::xint)
                         "tmXBLabels":   tmXBLabels(::xint)

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues(::yint)
                         "tmYLLabels":   tmYLLabels(::yint)

                         "tmYROn"           :   False
                         "tiYAxisString"    : "Percent"
						 
						
        end setvalues
        stats=stat_dispersion(data,False)
        statstr = (/"Mean = "+sprintf("%.2f",stats(0)),\
                    "Median = "+sprintf("%.2f",stats(8)),\
                    "Min = "+ sprintf("%.2f",stats(2)),\
                    "Max = "+sprintf("%.2f",stats(14))/)
       
            txtres               = True
            txtres@txFontHeightF = fheight
            txtres@txJust        = "BottomLeft"
           
            xptxt= tofloat(tmXBValues(::xint))
			
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)
			
			if opt.and.isatt(opt,"StringPosition")
				if opt@StringPosition .eq. "NE" then
					xp              = xptxt(nxm-1)-2*(abs(xptxt(1)-xptxt(0)))
					yp              = yptxt(nym-1)
				end if
				if opt@StringPosition .eq. "NW" then
					xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/8.
					yp              = yptxt(nym-1)
				end if	
			else
				xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/8.
				yp              = yptxt(nym-1)
			end if
    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.90*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.82*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.74*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.66*yp,txtres)

		draw(plot)
		frame(wks)
  		
 
end
undef("Hist_plt_diff_complicate") 
procedure Hist_plt_diff_complicate(data[*]:numeric,limts[4]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors:string\
                    ,tistrs[*]:string,statstr[*]:string\
                    ,opt:logical)
local res,plot,npct,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,stats,\
      statstr,txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4,opt,tistrs
begin
   
    npct = limts(3)
    pct1=dimsizes(data)/100.
    if opt.and. isatt(opt,"YMinF") then
		YMinPct   = opt@YMinF
	else
		YMinPct   = 0
	end if
	wks = gsn_open_wks(pltType, pltDir+pltName)
    gsn_define_colormap(wks,colors)

        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		 
  		res@tmXBMajorLengthF           = 0.01
		;res@tmXBLabelStride             = 2

        res@gsnHistogramMinMaxBinsOn   = True
        res@tiXAxisString              = tistrs(0)
       ;res@gsnHistogramBarColors       = "blue"
		;res@gsnHistogramBarColors       = cmap(29:72,:) 	
        res@tiYAxisOffsetXF            = 0.005
        res@tiXAxisOffsetYF            = 0.005
        res@gsnHistogramClassIntervals = fspan(limts(0),limts(1),limts(2))
        res@trYMinF = YMinPct*pct1

  		tmYLLabels  = ispan(YMinPct,npct,1)
        tmYLValues  = tmYLLabels*pct1

        
  		plot=gsn_histogram(wks,data,res)
		getvalues plot
            "tmXBLabels"             : tmXBLabels
            "tmXBValues"             : tmXBValues
            "tmYLLabelFontHeightF"   : fheight
        end getvalues
            nxm  = dimsizes(tmXBValues)
			xint = toint(nxm/6)
			nxm  = dimsizes(tmXBValues(::xint))
			yint = 1
			if nxm.gt.10 then
				xint = toint(xint*2)
			end if
			 nym = dimsizes(tmYLValues)
			 if nym.gt.5 then
				yint = toint(yint*(nym/5))
			end if
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues(::xint)
                         "tmXBLabels":   tmXBLabels(::xint)

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues(::yint)
                         "tmYLLabels":   tmYLLabels(::yint)

                         "tmYROn"           :   False
                         "tiYAxisString"    : "Percent"
						 "tiXAxisString"	: tistrs(1)
						 
						
        end setvalues
         
            txtres               = True
            txtres@txFontHeightF = fheight
            txtres@txJust        = "BottomLeft"
           
            xptxt= tofloat(tmXBValues(::xint))
			
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)
			
			if opt.and.isatt(opt,"StringPosition") then
				if opt@StringPosition .eq. "NE" then
					xp              = xptxt(nxm-1)-2.5*(abs(xptxt(1)-xptxt(0)))
					yp              = yptxt(nym-1)
				end if
				if opt@StringPosition .eq. "NW" then
					xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/8.
					yp              = yptxt(nym-1)
				end if	
			else
				xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/8.
				yp              = yptxt(nym-1)
			end if
    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.90*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.82*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.74*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.66*yp,txtres)
    dum5 = gsn_add_text(wks,plot,statstr(4),xp,0.58*yp,txtres)

		draw(plot)
		frame(wks)
end