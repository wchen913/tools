load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
; could be example of asciiread
begin
 yy   = "00"
 mon  = 5


 ncol = 9

 minT = 290 
 if mon.eq.5
	minT	= 280
 end if
 maxT = 325

 units = "(K)"
 stName = "DRA"

 plotFlag = True
 dytmFlag = True

 nplt		= 3
 pltpth		="~/tmp/"
 wksname1	= pltpth+"PDF_"+stName+"_"+sprinti("%0.2d",mon)
 
 if dytmFlag then
	 wksname1 = pltpth+"PDF_"+stName+"_"+yy+sprinti("%0.2d",mon)+"_day"
 end if

 if dytmFlag then
 	nrow = 4390
 	data		= asciiread(stName+"-GOES8_2000_DAY.DAT",(/nrow,ncol/),"float")
 	data2   	= asciiread(stName+"-GOES10_2000_DAY.DAT",(/nrow,ncol/),"float")
 else
	nrow = 8784
	data	=asciiread(stName+"-GOES8_2000_DAY-NIGHT.DAT",(/nrow,ncol/),"float")
 	data2	=asciiread(stName+"-GOES10_2000_DAY-NIGHT.DAT",(/nrow,ncol/),"float")
 end if
 yyyy		= data(:,0)     
 jday		= data(:,1)
 mm 		= data(:,2)
 dw_IR		= data(:,3)
 up_IR		= data(:,4)
 surfrad	= data(:,7)
 goes		= data(:,8)
;goes      = asciiread("goes8_4_dra.dat",-1,"float")  
 goesw     = data2(:,8)
;print(surfrad)
 
 inds       = ind(dw_IR.lt.0.)
 surfrad(inds)=-9999.9
 delete(inds)

 inds       = ind(up_IR.lt.0.)
 surfrad(inds)=-9999.9
 delete(inds)

 inds       = ind(surfrad.le.0.)
 surfrad(inds)= -9999.9
 goes(inds)   = -9999.9
 goesw(inds)  = -9999.9
 delete(inds)

 inds		= ind(goes.le.0.)
 goes(inds) = -9999.9
 delete(inds)

 inds		= ind(goesw.le.0.)
 goesw(inds) = -9999.9
 delete(inds)

 indm 		= ind(mm.eq.mon)
 
  x = surfrad(indm)
  y = goes(indm)
 ;y = goes
  z = goesw(indm)
  print(dimsizes(x))
;print(mm(indm)+" "+jday(indm))
;print(data2(indm,2)+" "+data2(indm,1))
;print(x(0:11))
  delete(data)
  delete(data2)
  x@_FillValue = -9999.9
  y@_FillValue = -9999.9
  z@_FillValue = -9999.9
 ;+++ 
	if plotFlag then
        plots   = new(nplt,graphic)
  		wks = gsn_open_wks("ps", wksname1+"y")
  		gsn_define_colormap(wks,"BlRe")
 
  		res1 = True
		res1@gsnFrame   = False
        res1@gsnDraw    				= False
  		res1@gsnMaximize         	  	= True 
        res1@gsnHistogramMinMaxBinsOn 	= True
		res1@gsnHistogramCompare         = False
		;res1@gsnHistogramBarWidthPercent = 50
  		;res1@tmXBLabelStride     	    = 6
  		res1@tiXAxisString     = yy+sprinti("%0.2d",mon)+" LST "+stName+units
        if dytmFlag then
			res1@tiXAxisString  = stName+" "+yy+sprinti("%0.2d",mon)+" daytime LST "+units
        end if
		nintvl  = toint(((maxT-minT)/5)+1)
  		res1@gsnHistogramClassIntervals = fspan(minT,maxT,nintvl)
        
        resTx                       = True
  		resTx@txPerimOn             = True
  		resTx@txFontHeightF         = 0.03
        resTx@txBackgroundFillColor = "LawnGreen" 

		resAno                  = True
  		resAno@amParallelPosF   = -0.5    ; This is the left edge of the plot.
  		resAno@amOrthogonalPosF = -0.5    ; This is the top edge of the plot.
  		resAno@amJust           = "TopLeft"

        
		anostr 	= "N = "+num(.not.ismissing(x)) 		
  		plots1=gsn_histogram(wks,x,res1)
       ;printVarSummary(plots1)
        
        nb   = dimsizes(plots1@EndBarLocs)
       ;print(nb)
		tmXBvalues	= plots1@EndBarLocs(0:nb-2)
        tmXBlabels  = ispan(minT,maxT,5)  		 
        setvalues plots1
			"tmXBMode"	:	"Explicit"
			"tmXBValues":	tmXBvalues
			"tmXBLabels":	tmXBlabels
        end setvalues
     	txid	= gsn_create_text(wks, anostr, resTx)
		anoid	= gsn_add_annotation(plots1, txid, resAno)
		draw(plots1)
		frame(wks)
 
        res1@gsnHistogramCompare         = True
        
		
        anostr 	= "N = "+num(.not.ismissing(y)) 
        
        if res1@gsnHistogramCompare then
			 res1@tiXAxisString    = "UMD_GOES8 (color).vs. "+stName+" (mesh) "+\
									 yy+sprinti("%0.2d",mon)+" LST "+units
        	if dytmFlag then
        		res1@tiXAxisString    = "UMD_GOES8 (color).vs. "+stName+" (mesh) "+\
									yy+sprinti("%0.2d",mon)+" daytime LST "+units
        	end if
			 data=new((/2,dimsizes(x)/),typeof(x),x@_FillValue)
             xtmp=x
             xtmp(ind(ismissing(y))) = x@_FillValue;
			 data(0,:)=(/y/)
             data(1,:)=(/xtmp/)
             printVarSummary(data)
			plots2=gsn_histogram(wks,data,res1)
			delete(data)
            delete(xtmp)
		else
			 res1@tiXAxisString    = "UMD_GOES8 "+\
									 yy+sprinti("%0.2d",mon)+" LST "+units
        	if dytmFlag then
        		res1@tiXAxisString    = "UMD_GOES8 "+\
									yy+sprinti("%0.2d",mon)+" daytime LST "+units
        	end if
			plots2=gsn_histogram(wks,y,res1)
		end if
       
        setvalues plots2
			"tmXBMode"	:	"Explicit"
			"tmXBValues":	tmXBvalues
			"tmXBLabels":	tmXBlabels
        end setvalues
		txid	= gsn_create_text(wks, anostr, resTx)
		anoid	= gsn_add_annotation(plots2, txid, resAno)
		draw(plots2)
		frame(wks)
        ;res1@gsnHistogramCompare         = True
        
		anostr 	= "N = "+num(.not.ismissing(z))
        if res1@gsnHistogramCompare then
			res1@tiXAxisString    = "UMD_GOES10 (color).vs."+stName+" (mesh) "+\
									yy+sprinti("%0.2d",mon)+" LST "+units
        	if dytmFlag then
        		res1@tiXAxisString    = "UMD_GOES10 (color).vs."+stName+" (mesh) "+\
										yy+sprinti("%0.2d",mon)+" daytime LST "+units
        	end if
			 data=new((/2,dimsizes(x)/),typeof(x),x@_FillValue)
             xtmp=x
             xtmp(ind(ismissing(z))) = x@_FillValue;
			 data(0,:)=(/z/)
             data(1,:)=(/xtmp/)
             printVarSummary(data)
			plots3=gsn_histogram(wks,data,res1)
		else
			res1@tiXAxisString    = "UMD_GOES10 "+\
									yy+sprinti("%0.2d",mon)+" LST "+units
        	if dytmFlag then
        		res1@tiXAxisString    = "UMD_GOES10 "+\
										yy+sprinti("%0.2d",mon)+" daytime LST "+units
        	end if
			plots3=gsn_histogram(wks,z,res1)
		end if 
               
        setvalues plots3
			"tmXBMode"	:	"Explicit"
			"tmXBValues":	tmXBvalues
			"tmXBLabels":	tmXBlabels
        end setvalues
		txid	= gsn_create_text(wks, anostr, resTx)
		anoid	= gsn_add_annotation(plots3, txid, resAno)
		draw(plots3)
		frame(wks)
        plots(0)=plots1
        plots(1)=plots2
        plots(2)=plots3
        resP              = True
        resP@gsnMaximize  = True
		resP@gsnPanelYWhiteSpacePercent = 3.
   		resP@gsnPanelXWhiteSpacePercent = 3.
       ;gsn_panel(wks,plots,(/1,3/),resP)
	end if

end


