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
    hist1 = npct@hist1
    hist2 = npct@hist2
    histnbin = npct@histnbin
    histc    = npct@histc
   
   
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
		res@gsnHistogramMinMaxBinsOn    = True
        res@gsnHistogramClassIntervals  = fspan(hist1,hist2,histnbin)

        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		res@gsnHistogramBarColors       = histc
		
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

  		

         nym  = dimsizes(tmYLValues)
			 yint = toint(nym/6)
            if yint.eq.0 then
                yint =1
            end if
			 nym = dimsizes(tmYLValues(::yint))	
		   
			if nym.gt.10 then
				yint = toint(yint*2)
			end if
            if yint.eq.0 then
                yint =1
            end if
  
           
            
		getvalues plot            
            "tmYLLabelFontHeightF"   : fheight
			"tmYLLabelFontThicknessF"   : fthick
            "tmXBValues":    tmXBValues
             "tmXBLabels":   tmXBLabels
        end getvalues
	    nxm   = dimsizes(tmXBValues)
        if nxm.gt.10 then
            xint = 2
        else
            xint = 1
        end if
        tmXBValues := tmXBValues(::xint)
        tmXBLabels := tmXBLabels(::xint)
        tmYLValues := tmYLValues(::yint)
        tmYLLabels := tmYLLabels(::yint)
        setvalues plot
                          "tmXBMode"  :   "Explicit"
                          "tmXBValues":   tmXBValues
                          "tmXBLabels":   tmXBLabels

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues
                         "tmYLLabels":   tmYLLabels
						
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




            bb  = NhlGetBB(plot)
            print(bb) ;(/t,b,l,r/)
			gsn_text_ndc(wks,"(x10~S~"+log10(pct1)+"~N~)",bb(2),0.87,txtres) 
           
			
 if opt.ne.0 then
	txtres@txJust        = "TopRight"
	txtres@txFontColor   = "red"
	yp              = yptxt(nym-1)
    xp              =xptxt(nxm-1)-(abs(xptxt(1)-xptxt(0)))/3.
	dum0   = gsn_add_text(wks,plot,tiXstr(1),xp,0.95*yp,txtres)
    txtres@txFontHeightF = fheight
    txtres@txJust = "TopLeft"
	txtres@txFontColor   = "black"
	xp   = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/3.
    dum1 = gsn_add_text(wks,plot,statstr,xp,0.95*yp,txtres)
   

end if
		draw(plot)
		frame(wks)

 
end
