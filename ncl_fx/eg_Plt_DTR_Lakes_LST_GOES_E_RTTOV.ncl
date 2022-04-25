load "$nclfx/addmeta.ncl"
load "/data/srb1/wchen/tools/ncl_fx/substring.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/Map_plt_fx.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters 
	varName  = "DTR"
	keywrd   = "interannul";"annual";"day";
	Region   = "LakeHuron"

	dy            = 10
	mon			  = 12
	year          = 2006
	if varName.eq."Tmin".or. varName.eq."Tmax"then		
				clim      = (/273,285,2,1/)
				hists     = (/273,285,7,1/)
	else
				clim      = (/1,9,1,2/)
				hists     = (/1,9,9,2/)
	end if
	
	;+++ Flags ; True; False
	Opt0    = True
	OptRdus = True
	pltMap	= True
	addHist = True
	pltHist = True

;+++ Parameters	
    yrstrt   = 2004
	mmstrt   = 1
	ddstrt   = 1
	hhstrt   = 0
	
    yrend    = 2009
	mmend    = 12
	ddend    = 31
	hhend    = 23
	
	tstrt    = yrstrt*1000000+mmstrt*10000+ddstrt*100+hhstrt
	tend     = yrend*1000000+mmend*10000+ddend*100+hhend
	
	timeStep = "daily"	
	sat      = "GOES_E"	 	
	lsmskopt = "land"

;+++++
	pltpth    = "./"
	pltname   = varName+"_"+Region+sat+"_"+yrstrt+"_"+yrend+"_"
	wkstype	  = "x11"
;+++ Parameters	
    UNDEF    = -999. 
    nhour    = 24   
	algstr   = "RTTOV_MERRA2_UMD"
	monstr      = (/"JAN","FEB","MAR","APR","MAY","JUN",\
                    "JUL","AUG","SEP","OCT","NOV","DEC"/)			    
   

	;------ Input
	pth         = "./"
    longname    =  "LST_"+str_upper(sat)+"_"+algstr
    ;LST.GOES_E.UMD.RTTOV.inst.2004010100.2009123123.LakeHuron.nc
    filename      = "DTR."+str_upper(sat)+".UMD.RTTOV."+timeStep+"."+tstrt+"."+tend+"."+Region
	if Opt0 then
		 filename = filename+"-0"
		 pltname  = pltname+"-0"
	end if;Opt0 ;ice free	
	print(filename)
	f 			  = addfile(pth+filename+".nc","r")
	data        = f->$varName$
	 
	dimsize       = dimsizes(data)
	lat			  = f->lat
	lon			  = f->lon
	delete(f)

	printVarSummary(data)
	;------ Time Stamp
	yyyymmdd      = data&time 
	yyyy          = toint(yyyymmdd/10000)
	mmdd          = yyyymmdd-yyyy*10000
    mm            = toint(mmdd/100)
    dd            = mmdd-mm*100
	
	;+++++ land-sea mask +++++
	if lsmskopt.eq."land" then
		f             = addfile("./lsmsk.LakeHuron.S-N.W-E.nc","r")
		lsm           = f->lsm
		lsm!0         = "lat"
		lsm!1         = "lon"
		lsm&lat       = f->lat
		lsm&lon       = f->lon
		lsmsk		  = conform(data,lsm,(/1,2/))
		data        = mask(data,lsmsk.eq.0,False)   
	end if
 
	printMinMax(data,True)
	
;------ Plotting 
if pltMap then
		
	    tistr     = ""
		if keywrd.eq."day" then ;needs to tell the Year/Mon/Day
			 
			wksname= pltname+"_"+keywrd+"_1MP1dd"+year+sprinti("%0.2i", mon)+sprinti("%0.2i", dy)
			print(wksname)
			lftstr= varName 
			rtstr = year+"/"+sprinti("%0.2i", mon)+"/"+sprinti("%0.2i", dy)	
			
			inds  	  = ind(yyyy.eq.year.and.mm.eq.mon.and.dd.eq.dy)
			data_clim = data(inds,:,:)			 
			pltdata   = data_clim			 
			
			delete(data_clim)
			delete(inds)
		end if
		
		if keywrd.eq."annual" then ;needs to tell mon
			if mon.le.12 then
				data_clim = new((/12,81,121/),typeof(data),UNDEF)
				do imm    = 0,11
					inds           = ind(mm.eq.imm+1)
					data_clim(imm,:,:) = dim_avg_n_Wrap(data(inds,:,:),0)
					delete(inds)
				end do;imm
				printVarSummary(data_clim)
				printMinMax(data_clim,True)
				
				rtstr = varName
				lftstr= monstr(mon-1)			
				wksname= pltname+"_"+keywrd+"_1MP1mm"+sprinti("%0.2i", mon)
				print(wksname)			
			 
				pltdata   = data_clim(mon-1,:,:)
				delete(data_clim)
			else
				pltdata   = dim_avg_n_Wrap(data,0)
 				rtstr = varName
				lftstr= "Annual"		
				wksname= pltname+"_"+keywrd+"_1MPAll"
			end if;mon.le.12
			
			
 		end if;keywrd.eq."annual"
		if keywrd.eq."interannul" then
			print(year)
			if mon.le.12 then
				data_clim = new((/6,12,81,121/),typeof(data),UNDEF)
				do iyr    = yrstrt,yrend
				do imm    = 0,11
					inds           = ind(mm.eq.imm+1.and.yyyy.eq.iyr)
					data_clim(iyr-2004,imm,:,:) = dim_avg_n_Wrap(data(inds,:,:),0)
					delete(inds)
				end do;imm
				end do;iyr 
				printVarSummary(data_clim)
				printMinMax(data_clim,True)
 				pltdata   = data_clim(year-2004,mon-1,:,:)
				rtstr = varName
				lftstr= monstr(mon-1)+","+year		
				wksname= pltname+"_"+keywrd+"_1MP1yy1mm"+year+sprinti("%0.2i", mon)
				print(wksname)	
			else				
				data_clim = new((/6,81,121/),typeof(data),UNDEF)
				do iyr    = yrstrt,yrend
					inds           = ind(yyyy.eq.iyr)
					data_clim(iyr-2004,:,:) = dim_avg_n_Wrap(data(inds,:,:),0)
					delete(inds)
				end do
				printVarSummary(data_clim)
				printMinMax(data_clim,True)
 				pltdata   = data_clim(year-2004,:,:)
				rtstr = varName
				lftstr= year		
				wksname= pltname+"_"+keywrd+"_1MP1yy"+year
				print(wksname)	
			end if;mon.le.12
			delete(data_clim)
		end if;keywrd.eq."interannul" 
		printVarSummary(pltdata)
		printMinMax(pltdata,True)
	    delete(pltdata@long_name)
	    delete(pltdata@units)
		
	;+++++ Map Plotting
	    print("Map Plotting")		
   		wks = gsn_open_wks(wkstype, pltpth+"map_"+wksname)
   		gsn_define_colormap(wks,"MPL_autumn")
		gsn_reverse_colormap(wks)
		
		printMinMax(pltdata,True)
	if OptRdus
	    stdt  = stddev(pltdata)/2.

		if varName.eq."DTR" .and.(mon.gt.12 .or. mon.eq.10) then;
			;pltdata  = where(pltdata.lt.4,3.75,pltdata)
			 pltdata = (/smth9(pltdata,0.5,0.5,False)/)

		end if
		if varName.eq."DTR" .and.mon.eq.7 then;
				pltdata = (/smth9(pltdata,0.5,0.5,False)/)
				pltdata = (/smth9(pltdata,0.5,0.5,False)/)
		end if
		pltdata = (/smth9(pltdata,0.5,0.5,False)/)
		pltdata = where((pltdata.gt.hists(1)+stdt).or.(pltdata.lt.hists(0)-stdt),UNDEF,pltdata)

	end if
		printMinMax(pltdata,True)
	    plot=Map_Plot_Region(wks,pltdata,clim,lsmskopt,"MediumRes");"HighRes"
  		
	getvalues plot
            "tmYLLabelFontHeightF"   : fheight
    end getvalues

    txres               = True
    txres@txFontHeightF = fheight*1.25
    txres@txJust        = "BottomLeft"
    txres@txFontColor   = "red"
    dum1=gsn_add_text(wks,plot,rtstr,-84.75,43.25,txres)
    txres@txFontColor   = "Blue"
    dum2=gsn_add_text(wks,plot,lftstr,-81,43.25,txres)
   
   draw(plot)

   		
   
;+++ Add Histogram
    if addHist  then
    startlat = 46
    startlon = -80.5
    lonw     = 1.4
    lath     = 1
    xndc     = new(2,"float")
    yndc     = new(2,"float")

    datatondc(plot,(/startlon,startlon+lonw/),(/startlat,startlat+lath/),xndc,yndc)
  ;gsn_define_colormap(wks,"MPL_autumn");"WhBlReWh"
      histres = True
      histres@vpXF   = xndc(0)
      histres@vpYF   = yndc(1)
      histres@vpWidthF = xndc(1)-xndc(0)
      histres@vpHeightF= yndc(1)-yndc(0)
      
      histres@gsnHistogramBarColors= "white";"red";"plum"

      histres@gsnHistogramBarWidthPercent = 100
      histres@tmXBMajorLengthF           = 0.01
      histres@gsnHistogramMinMaxBinsOn   = True;False; 
      histres@tmYROn          = False
      histres@tmYLOn          = False
      histres@tmYLMinorOn     = False
      histres@tmXTOn          = False
      histres@tmYRBorderOn    = False
     ;histres@tmYLBorderOn    = False

      histres@gsnHistogramClassIntervals = fspan(hists(0),hists(1),hists(2))
      histres@tmXBLabelStride            = hists(3)
      histres@tmXBLabelFontHeightF       = fheight*0.5
      histres@tiYAxisOn = False
      histres@tiXAxisOn = False
      histres@tmXBLabelDeltaF   = -0.55
      pltdata  = where(pltdata.lt.hists(0)-1,UNDEF,pltdata)
      pltdata  = where(pltdata.gt.hists(1)+1,UNDEF,pltdata)

      histogram=gsn_histogram(wks,ndtooned(pltdata),histres)

	end if;addHist
       
    end if ;pltMap
	;+++++ Histogram Plotting

    if pltHist then
		wks = gsn_open_wks(wkstype, pltpth+"Hist_"+wksname)
   		
		histres = True 
		histres@gsnFrame        = False                    ; don"t advance frame yet
		histres@gsnDraw         = False
		histres@gsnMaximize         = True 
		histres@gsnHistogramBarColors= "orangered"
		histres@gsnHistogramClassIntervals = fspan(hists(0),hists(1),hists(2))
		
		histres@gsnHistogramBarWidthPercent = 100
		histres@tmXBMajorLengthF           = 0.01
		histres@gsnHistogramMinMaxBinsOn   = True;False; 
		histres@tmYROn          = False       
		histres@tmYLMinorOn     = False
		histres@tmXTOn          = False 
		
		histres@tmXBLabelStride            = hists(3)
		histres@tmXBLabelFontHeightF       = fheight
        histres@tiYAxisOn = False
        histres@tiXAxisOn = False
        histres@tmXBLabelDeltaF   = -0.55
		
		

		histogram=gsn_histogram(wks,ndtooned(pltdata),histres)

		
	    draw(histogram)
	end if;pltHist
 
	print("done")


end
;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if

;tmp   = dataAvg(hour,:,:)
;delete(dataAvg)
;tmp  = data(day,hour,:,:) 
;tmp  = addmeta(tmp,dimsz(2:3),dimNames(2:3),geoinfo,longname,units,-1,-1)
;day		 = 12  
;hour	 = 17 
;nrec	 = (day-1)*nhour+hour

   ;res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   ;res@mpFillOn            = False
   ;res@lbOrientation       = "Vertical"
   ;res@lbLabelAutoStride   = True    
   ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
  ;res@cnFillMode          = "CellFill"  
 ;res1@gsnHistogramSelectNiceIntervals = False
  ;res1@gsnHistogramNumberOfBins        = 61 
  ;res1@gsnHistogramComputePercentages	= True
   ;res1@gsnHistogramPercentSign		= True
