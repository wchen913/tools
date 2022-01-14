;***************************************** 
;	This script is for Histogram Plotting
;*****************************************
undef("Hist_plt_value") 
procedure Hist_plt_value(data[*]:numeric,limts[4]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors[1]:string\
                    ,tiXstr[1]:string\
                    ,opt)
local res,plot,npct,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,stats,\
      statstr,txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4
begin
   
    npct = limts(3)
    pct1=dimsizes(data)/100.
    
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		 
  		res@tmXBMajorLengthF           = 0.01
        res@gsnHistogramMinMaxBinsOn   = False
        res@tiXAxisString              = tiXstr
        
        res@tiYAxisOffsetXF            = 0.005
        res@tiXAxisOffsetYF            = 0.005
        res@gsnHistogramClassIntervals = fspan(limts(0),limts(1),limts(2))
        
  		tmYLLabels  = ispan(0,npct,1)
        tmYLValues  = tmYLLabels*pct1


        wks = gsn_open_wks(pltType, pltDir+pltName)
        gsn_define_colormap(wks,colors)

  		plot=gsn_histogram(wks,data,res)
		getvalues plot
            "tmXBLabels"             : tmXBLabels
            "tmXBValues"             : tmXBValues
            "tmYLLabelFontHeightF"   : fheight
        end getvalues
     
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues(::10)
                         "tmXBLabels":   tmXBLabels(::10)

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues
                         "tmYLLabels":   tmYLLabels

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

            xptxt= tofloat(tmXBValues(::20))
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)

            xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/8.
            yp              = yptxt(nym-2)

    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.96*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.88*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.80*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.72*yp,txtres)

		draw(plot)
		frame(wks)
  		
 
end

undef("Hist_plt_diff_temp") 
procedure Hist_plt_diff_temp(data[*]:numeric,npct:numeric\
                        ,statstr[5]:string\
                        ,pltType[1]:string, pltDir[1]:string\
                        ,pltName[1]:string\
                        ,tiXstr[1]:string\
                        ,opt)
local res,plot,pct1,tmYLLabels,tmYLValues,tmXBLabels,tmXBValues,fheight,\
      txtres,xptxt,yptxt,xp,yp,nxm,nym,dum1,dum2,dum3,dum4,dum5,cmap
begin
   
    
    pct1=dimsizes(data)/100.
    cmap = read_colormap_file("WhBlReWh")
 printVarSummary(cmap)
   
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        
        
  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		res@gsnHistogramBarColors       = cmap(29:72,:) 
  		
  		res@tmXBMajorLengthF            = 0.01
        res@gsnHistogramMinMaxBinsOn    = True
        
        res@tiXAxisString               = tiXstr
        
        res@tiYAxisOffsetXF             = 0.005
        res@tiXAxisOffsetYF             = 0.005
        res@gsnHistogramClassIntervals  = fspan(-20,20,41)
        
  		tmYLLabels  = ispan(0,npct,1)
        tmYLValues  = tmYLLabels*pct1


        wks = gsn_open_wks(pltType, pltDir+pltName)
       ;gsn_define_colormap(wks,"WhBlReWh")

        
  		plot=gsn_histogram(wks,data,res)

  		tmXBValues    = plot@EndBarLocs(::5)
        tmXBLabels    = ispan(-20,20,5)

		getvalues plot            
            "tmYLLabelFontHeightF"   : fheight
        end getvalues
     
        setvalues plot
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues
                         "tmXBLabels":   tmXBLabels

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues
                         "tmYLLabels":   tmYLLabels

                         "tmYROn"           :   False
                         "tiYAxisString"    : "Percent"
        end setvalues
       
       
            txtres               = True
            txtres@txFontHeightF = fheight*0.875
            txtres@txJust        = "BottomLeft"

            xptxt= tofloat(tmXBValues)
            yptxt= tmYLValues
            nym = dimsizes(yptxt)
            nxm = dimsizes(xptxt)

            xp              = xptxt(0)+(abs(xptxt(1)-xptxt(0)))/10.
            yp              = (yptxt(nym-1)+yptxt(nym-2))/2.

    dum1 = gsn_add_text(wks,plot,statstr(0),xp,0.98*yp,txtres)
    dum2 = gsn_add_text(wks,plot,statstr(1),xp,0.90*yp,txtres)
    dum3 = gsn_add_text(wks,plot,statstr(2),xp,0.82*yp,txtres)
    dum4 = gsn_add_text(wks,plot,statstr(3),xp,0.74*yp,txtres)
    dum5 = gsn_add_text(wks,plot,statstr(4),xp,0.66*yp,txtres)
		draw(plot)
		frame(wks)
  		
 
end
  
