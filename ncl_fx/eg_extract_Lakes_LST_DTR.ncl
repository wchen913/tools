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
	
	timeStep = "inst"
	
	sat      = "GOES_E"
	 
	Region   = "LakeHuron"
	
	lsmskopt = "none"
	keywrd   = "interannuldiurnal";"day";"interannul";"annual";"diurnal";
	
	hour          = 19
	dy            = 10
	mon			  = 5
	year          = 2008
;+++ Flags
    Opt0	= True ;ice free
	svdata  = True
	pltMap	= False
	pltHist = True
;+++++
	pltpth    = "./"
	pltname   = Region+"_LST_"+sat+"_"+yrstrt+"_"+yrend
	wkstype	  = "pdf"
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
    filename      = str_upper(varName)+"."+str_upper(sat)+".UMD.RTTOV."+timeStep+"."+tstrt+"."+tend+"."+Region+".nc"
	print(filename)
	f 			  = addfile(pth+filename,"r")
	data        = f->$str_upper(varName)$
	data        = where(data.ge.220.and.data.le.400,data,UNDEF)
	if Opt0 then
		data        = where(data.ge.1.and.data.lt.273,273,data)
	end if;Opt0 ;ice free
	dimsize       = dimsizes(data)
	lat			  = f->lat
	lon			  = f->lon
	delete(f)
	printVarSummary(data)

	;------ Time Stamp
	date      	  = calendar_decode2(data&time,-5)
	print(date(0,:))

	yyyy          = date(::24,0)
 	mm            = date(::24,1)
	dd            = date(::24,2)
	hh			  = date(::24,3)
	yyyymmdd      = yyyy*10000+mm*100+dd
	ntime		  = dimsizes(yyyymmdd)
	data		  := reshape(data,(/ntime,24,dimsize(1),dimsize(2)/))
	data@_FillValue = UNDEF
	data!0		= "time"
	data&time 	= yyyymmdd
	data!1		= "hour"
	data&hour	= ispan(0,23,1)
	data!2		= "lat"
	data&lat	= lat
	data!3		= "lon"
	data&lon	= lon
	
	printVarSummary(data)
	printMinMax(data,True)
	Tmin        = dim_min_n_Wrap(data,1)
	Tmax        = dim_max_n_Wrap(data,1)
	DTR         = abs(Tmax-Tmin)
	printVarSummary(Tmin)
	printMinMax(Tmin,True)
	printVarSummary(Tmax)
	printMinMax(Tmax,True)
	copy_VarCoords(Tmax,DTR)
	printVarSummary(DTR)
	printMinMax(DTR,True)
	;+++++ land-sea mask +++++
	if lsmskopt.eq."land" then
		f             = addfile("./lsmsk.LakeHuron.S-N.W-E.nc","r")
		lsm           = f->lsm
		lsm!0         = "lat"
		lsm!1         = "lon"
		lsm&lat       = f->lat
		lsm&lon       = f->lon
		lsmsk		  = conform(data,lsm,(/2,3/))
		data        = mask(data,lsmsk.eq.0,False)   
	end if
 
	 
	 
if svdata  then
         print("Write NetCDF Data")
       
         opth = "./"
         fname = opth+"DTR."+str_upper(sat)+".UMD.RTTOV.daily."+tstrt+"."+tend+"."+Region
	if Opt0 then
		 fname = fname+"-0"
	end if;Opt0 ;ice free		 
         print(fname)
         
         system("/bin/rm -f "+fname+".nc")
         fod                 = addfile(fname+".nc"  ,"c")
         fod->DTR            = DTR
         fod->Tmin           = Tmin
		 fod->Tmax           = Tmax
       delete(fod)
 end if ;svdata  	
 
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
