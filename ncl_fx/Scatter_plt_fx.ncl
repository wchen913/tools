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
;(data,dimsize,dimnames,geoinfo[latS,latN,lonW,lonE],longname,units,opttime,optlev)
load "$nclfx/addmeta.ncl" 
;*******************************************************
; Scattering plot with best fit line and 5 statistics
undef("scatter_bestfit_s5")
;*******************************************************
procedure scatter_bestfit_s5(x:numeric,\
						    y:numeric,\
						    wksctrl[2]:string,\ 	; control wkstype and wksname
						    xlimylim[4]:numeric,\ 	; control max/min value of x/y axis
						    labelstrs[5]:string,\ 	; title;x/y axis labels;left/right string
						    makerstyle:string,\ 	; triangle/solid circle	
							txposp[3]:numeric,\	    ; text x/y position portion and y interval
						    opto:logical)			; remove outliers

local diff,Corr,Bias,N,Std,RMS,dof,inds,rc,z,textstr,txres,res,wkstype,wksname,\
	  xlabel,ylabel,tistr,leftstr,rightstr,tmXBValues,tmYLValues,\
	  txpx,txpy,txYint,ntym,ntxm,wks,plot,plotl,dum1,dum2,dum3,dum4,dum5

begin
;-----  specifications  
   wkstype  = wksctrl(0)
   wksname  = wksctrl(1)

   xlim		= xlimylim(0:1)
   ylim     = xlimylim(2:3)  

   tistr 	= labelstrs(0)
   xlabel	= labelstrs(1)
   ylabel   = labelstrs(2)
   leftstr  = labelstrs(3)
   rightstr = labelstrs(4)
   txpx     = txposp(0)
   txpy     = txposp(1)
   txYint   = txposp(2)
;----- Calculate statistics	
    diff = y-x
  	Corr = esccr(x,y,0)
  	Bias = avg(diff)
  	N    = num(.not.ismissing(diff))
  	Std  = stddev(diff)
  	RMS  = sqrt(Bias*Bias) 

	if opto then
	   dof	   = N
       inds	   = ind(abs(diff).gt.(3*Std))
	   x(inds) = x@_FillValue
	   y(inds) = y@_FillValue
       diff    = y-x
	   Corr = esccr(x,y,0)
  	   Bias = avg(diff)
  	   N    = num(.not.ismissing(diff))
  	   Std  = stddev(diff)
  	   RMS  = sqrt(Bias*Bias) 
    end if
   ;+++ Best fit
	rc		= regline(x,y)
    z       = rc*(x-rc@xave)+rc@yave
   ;printVarSummary(z)
	  if opto then
            numStr="N = "+N+" ( "+sprintf("%.1f",tofloat(N)/tofloat(dof)*100.)+"% )"
        else
            numStr="N = "+N
        end if

  	textstr = (/"Corr = "+sprintf("%.2f",Corr),\
			  "Bias = "+sprintf("%.2f",Bias)+" ( "+sprintf("%.1f",abs(Bias/avg(x))*100)+"% )",\
			  "RMS = "+sprintf("%.2f",RMS)+" ( "+sprintf("%.1f",abs(RMS/avg(x))*100)+"% )",\
			   numStr,\
			  "Std = "+sprintf("%.2f",Std)+" ( "+sprintf("%.1f",abs(Std/avg(x))*100)+"% )"/) 
	print(textstr)

;----- plotting
 	wks   = gsn_open_wks (wkstype,wksname)            ; open workstation

 	res                   = True
 	res@gsnDraw   		  = False                             ; don't draw yet
  	res@gsnFrame  		  = False 
	res@gsnMaximize 	  = True

   
    ;res@vpXF             = 0.15                
 	;res@vpYF             = 0.8                
 	;res@vpHeightF        = 0.5                
 	;res@vpWidthF         = 0.65 
    
                     
 	res@tiMainString      = tistr
    res@tiMainFontHeightF = 0.02 
    res@tiMainOffsetYF	  = 0.05
      
 	res@xyMarkLineModes   = "Markers"                	
    if makerstyle.eq."triangle" then ; filled triangle
 		res@xyMarkers         =  NhlNewMarker(wks,"u",34,0.0,0.0,1.3125,1.5,0.0)
	else 							 ;filled circle
		res@xyMarkers         =  16;
	end if
    res@xyMarkerColor     = "blue"                   
 	res@xyMarkerSizeF     = 0.015     ; Marker size (default 0.01)
    
	res@trXMinF	= xlim(0)
    res@trXMaxF	= xlim(1)
    res@trYMinF	= ylim(0)
    res@trYMaxF = ylim(1)


    res@tmBorderThicknessF= 4.0

 	res@tmLabelAutoStride = True                      
 	res@tmYROn            = False
 	res@tmXTOn            = False
 	res@tmYLMinorOn       = False
 	res@tmXBMinorOn       = False

    res@tmXBMajorThicknessF     = 4.0
    res@tmYLMajorThicknessF  	= 4.0 
    res@tmXBLabelFontThicknessF = 4.0
    res@tmYLLabelFontThicknessF = 4.0
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
 

    getvalues plot
    "tmXBValues"             : tmXBValues  
    "tmYLValues"             : tmYLValues
    end getvalues
 
    ntym = dimsizes(tmYLValues)
    ntxm = dimsizes(tmXBValues)

	 txres               = True
     txres@txFontHeightF = 0.03 
     txres@txJust        = "BottomLeft"

dum1=gsn_add_text(wks,plot,textstr(0),\		; Corr
txpx*tmXBValues(ntxm-1),txpy*tmYLValues(ntym-1),txres)

dum2=gsn_add_text(wks,plot,textstr(1),\		; Bias
txpx*tmXBValues(ntxm-1),(txpy-txYint)*tmYLValues(ntym-1),txres)

dum3=gsn_add_text(wks,plot,textstr(2),\		; RMS
txpx*tmXBValues(ntxm-1),(txpy-2*txYint)*tmYLValues(ntym-1),txres)

dum4=gsn_add_text(wks,plot,textstr(4),\		; Std
txpx*tmXBValues(ntxm-1),(txpy-3*txYint)*tmYLValues(ntym-1),txres)

dum5=gsn_add_text(wks,plot,textstr(3),\		; N
txpx*tmXBValues(ntxm-1),(txpy-4*txYint)*tmYLValues(ntym-1),txres)

   
     	 
       res@xyMarkLineModes   = "Lines"
       res@xyLineThicknesses = 5.
	   res@xyLineColor       = "red"
       plotl = gsn_csm_xy (wks,x,z,res)
	   overlay(plot,plotl)
       draw(plot)
 

end

