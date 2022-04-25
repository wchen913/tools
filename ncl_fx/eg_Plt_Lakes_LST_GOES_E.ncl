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

	varName  = "lst"
	Region   = "LakeHuron"		
	sat      = "GOES_E"	
	algstr   = "UMD_RTTOV_MERRA2_LUT"
	timeStep = "inst"	 

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
	
	UNDEF    = -999. 
    nhour    = 24   
	KeyStr   = Region+"_LST_"+sat+"_"+yrstrt+"_"+yrend
	 
;+++ Flags
 	pltHist = False
 	lsmskopt = "land"
;+++ Parameters	  
	monstr   = (/"January","February","March","April","May","June",\
                    "July","August","September","October","November","December"/)			    
   lbstr	= (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)"/)
;------ Input
	pth         = "./"
    longname    =  "LST_"+str_upper(sat)+"_"+algstr
    ;LST.GOES_E.UMD.RTTOV.inst.2004010100.2009123123.LakeHuron.nc
    filename      = str_upper(varName)+"."+str_upper(sat)+".UMD.RTTOV."+timeStep+"."+tstrt+"."+tend+"."+Region+".nc"
	print(filename)
	f 			  = addfile(pth+filename,"r")
	data        = f->$str_upper(varName)$
	data        = where(data.lt.-33..and.data.gt.400,UNDEF,data)
	dimsize       = dimsizes(data)
	lat			  = f->lat
	lon			  = f->lon
	delete(f)
	printVarSummary(data)
;------ Time Stamp
	date      	  = calendar_decode2(data&time,-5)
	print(date(0,:))

	yyyy          = date(:,0)
 	mm            = date(:,1)
	dd            = date(:,2)
	hh			  = date(:,3)
 
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
 
	QC            = where(ismissing(data),0.,1.)
	copy_VarCoords(data,QC)
	printVarSummary(QC)
    hours	= (/6,18,0,12/);(/0,6,12,18/)
;-------- All year around hours	= (/0,6,12,18/) 
	data_clim_hh = data(0:3,:,:)
	data_clim_hh&time := hours
	QC_clim_hh  = QC(0:3,:,:)
	QC_clim_hh&time := hours
	printVarSummary(data_clim_hh)
	printVarSummary(QC_clim_hh)
	
	
	clim      = (/270,300,1,5/)
	hists     = (/270,300,31,5/) 
	lftstr= "Annual"
	rtstr = "UTC "+sprinti("%0.2i", hours)
	do ihr  = 0,1;0,3
		inds					:= 	ind(hh.eq.hours(ihr)) 
		data_clim_hh(ihr,:,:)	= 	dim_avg_n_Wrap(data(inds,:,:),0)
		QC_clim_hh(ihr,:,:)		= 	dim_sum_n_Wrap(QC(inds,:,:),0)
		printMinMax(data_clim_hh,True)
		printMinMax(QC_clim_hh,True)
	end do;ihr	
;-------- JAN hours	= (/0,6,12,18/)
	data_clim_m1h 	= 	data_clim_hh
 	QC_clim_m1h   	=  	QC_clim_hh
	
	do ihr  = 0,1;0,3
		inds					:= 	ind(mm.eq.1.and.hh.eq.hours(ihr))
		data_clim_m1h(ihr,:,:)	= 	dim_avg_n_Wrap(data(inds,:,:),0)
		QC_clim_m1h(ihr,:,:)	= 	dim_sum_n_Wrap(QC(inds,:,:),0)		 
		printMinMax(data_clim_m1h,True)
		printMinMax(QC_clim_m1h,True) 
	end do; ihr
;-------- JUL hours	= (/0,6,12,18/)
	data_clim_m7h 	= 	data_clim_hh
 	QC_clim_m7h   	=  	QC_clim_hh
	lftstr			= 	"July"
	clim      		= 	(/275,305,1,5/)
	hists     		= 	(/275,305,16,2/) 
	do ihr  = 0,1;0,3
		inds					:= 	ind(mm.eq.7.and.hh.eq.hours(ihr))
		data_clim_m7h(ihr,:,:)	= 	dim_avg_n_Wrap(data(inds,:,:),0)
		QC_clim_m7h(ihr,:,:)	= 	dim_sum_n_Wrap(QC(inds,:,:),0)		 
		printMinMax(data_clim_m7h,True)
		printMinMax(QC_clim_m7h,True) 
	end do; ihr	
print("----------------- Map Plotting ---------------------------")
    pltpth  = "./figs/"
	wksname	= KeyStr+"_"+"mm1-mm7-mm13_hours"
	wkstype	= "x11";"pdf"
	tistr   = ""

	plots = new ( 4, "graphic") 
	wks = gsn_open_wks(wkstype, pltpth+"map_panel_"+wksname+"_pub")
	gsn_define_colormap(wks,"BlGrYeOrReVi200");MPL_autumn
	;gsn_reverse_colormap(wks)
    txres               = True
    txres@txFontHeightF = fheight*1.25
    
    lftstr			= 	"January"
	clim      		= 	(/270,280,1,2/)
	hists     		= 	(/260,290,31,5/) 
    do iplt = 0,1
    	pltdata	= 	data_clim_m1h(iplt,:,:)
		pltdata = (/smth9(pltdata,0.5,0.5,False)/)	
		plot=Map_Plot_Region(wks,pltdata,clim,lsmskopt,"MediumRes");"HighRes"
		draw(plot)

	    getvalues plot     
			"tmYLLabelFontHeightF"   : fheight   
		end getvalues
		plot@dum1 = gsn_add_text(wks,plot,"UTC "+sprinti("%0.2i",hours(iplt)) ,-80,46.5,txres)
  		plot@dum2 = gsn_add_text(wks,plot,"January" ,-81.5,43.5,txres)
  		frame(wks)
	end do
	
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
		
		printMinMax(pltdata,True)
		histogram=gsn_histogram(wks,ndtooned(pltdata),histres)

		
	    draw(histogram)
		frame(wks)
        ;pltdata  = (/QC_clim({43:47},{-85:-79})/)
		;printMinMax(pltdata,True)
        
        ;printVarSummary(pltdata)
        ;hists      = (/100,1000,10,2/)	
		;delete(histres@gsnHistogramClassIntervals)
        ;histres@gsnHistogramClassIntervals = fspan(hists(0),hists(1),hists(2))
		;histogram1=gsn_histogram(wks,ndtooned(pltdata),histres)
        ;N = num(.not.ismissing(ndtooned(pltdata)))
        ;print(N)
        ;draw(histogram1)
		;clim      = (/0,180*6,200,2/)			
	   ; plot=Map_Plot_Region(wks,pltdata,clim,opt,"MediumRes");"HighRes"
	   ; draw(plot)

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
