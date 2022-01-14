;***************************************** 
;	This script is for Histogram Plotting
;*****************************************

undef("hist_plt_fx") 
function hist_plt_fx(wks:graphic,datain[*]:numeric,limts[4]:numeric,tistr[2]:string,opt:logical)
local res,plot,pct1,inds,data
begin
   
	inds	:= ind(.not.(ismissing(datain))) 
	data	= datain(inds)
    pct1	= dimsizes(data)/100.    
 
        res = True
		res@gsnFrame                    = False
        res@gsnDraw    				    = False
        res@gsnHistogramBarColors      	= "blue"			
        res@gsnHistogramMinMaxBinsOn    = False

  		res@gsnMaximize         	  	= True 
		res@gsnHistogramBarWidthPercent = 100
  		res@tmYROn          			= False       
		res@tmYLMinorOn     			= False
		res@tmXTOn          			= False 
  		res@tmXBMajorLengthF           = 0.01
		res@tmXBLabelStride            = limts(3)
		res@tmYLLabelDeltaF   = -0.65
		res@tmXBLabelDeltaF   = -0.55
		if isatt(opt,"YStride") then
 			res@tmYLLabelStride        = opt@YStride
 		end if
 		res@tmXBLabelFontHeightF       = 0.025
		res@tmYLLabelFontHeightF       = 0.025
		res@tmYLLabelFontThicknessF    = 3.5
		res@tmXBLabelFontThicknessF    = 3.5
	    
        res@tiXAxisString           = tistr(0)
        res@tiYAxisString           = tistr(1)
        res@tiXAxisFontHeightF		= 0.0275
		res@tiYAxisFontHeightF		= 0.0275
		res@tiXAxisFontThicknessF   = 3.5
		res@tiYAxisFontThicknessF   = 3.5
        res@tiYAxisOffsetXF         = 0.008
        res@tiXAxisOffsetYF         = 0.007
        if isatt(opt,"tmYFormat") then
       		res@tmYLFormat				= opt@tmYFormat
		end if
        res@gsnHistogramClassIntervals = fspan(limts(0),limts(1),toint(limts(2)))
 		if isatt(opt,"YNpctF") then
			res@trYMaxF =	opt@YNpctF*pct1
		else
			res@trYMaxF =	50*pct1 
		end if
		if isatt(opt,"YMaxF") then
			res@trYMaxF =	opt@YMaxF		 
		end if
  		plot=gsn_histogram(wks,data,res)
		
		return(plot)
end
