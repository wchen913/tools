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
   yrstrt   = 2004
   yrend    = 2009

	sat      = "GOES_E"
	if sat.eq."GOES_E" then	
	   mnt      = "15"
	else
	   mnt      = "30"
	end if
	iskm     = 4

   ;mon      = 1
   ;hour     = 0;18;
    
	opt      = "no" ;"land";"water";"no";mask
;+++ Flags
    landmask    	= False
    watermask     = False
    
    svdata        = True 
    pltMap        = True
    
    pltHist       = False 
  
    histclm       = False
    
;+++ Parameters	
    resS     = 0.05 ;spatial resolution
    nhour    = 24   
	nLat	 = 501
	nLon	 = 1101

	geoinfo  = (/25,50,-125.,-70/)
	dimsz	 = (/nLat,nLon/)
	dimNames = (/"lat","lon"/)
	datatype = "float"
	units	 = "(K)"
	nrec	 = 0
    UNDEF  = -999.
	skms  = (/"skm.i.11um_wv",\                ;0
	          "skm.i.WisEmis_GCIP",\           ;1
	          "skm.i.WisEmis_MERRA2",\         ;2
	          "skm.i.sglChan",\                ;3
             "skm.i.RTTOV_MERRA2_LUT",\       ;4
				 "skm.i.proposedSplitWindow"/)    ;5
				    
    pth         = "/data/srb2/wchen/LST/"+sat+"/output/"
    longname    =  str_upper(sat)+" LST"+" (UMD."+substring(skms(iskm),0,10)+".000)" ;str_sub_str(skms(iskm),"_",".")
   
;+++ Plotting Path & file names & settings

;+++ Time Coverage
   yyyymmddhh    = yyyymmddhh_time(yrstrt,yrend,1,"integer")
   yyyy          = toint(yyyymmddhh/1000000)
   mmddhh        = yyyymmddhh-yyyy*1000000
   mm            = toint(mmddhh/10000)
   ddhh          = mmddhh-mm*10000
   dd            = toint(ddhh/100)
   hh            = toint(ddhh-dd*100)
   delete(mmddhh)
   delete(ddhh)
  ;print(yyyy(0)+" "+mm(0)+" "+dd(0)+" "+hh(23))
   ntime         = dimsizes(yyyymmddhh)
    ;LakeHuron{43:47},{-85:-79} 
    ;LakeMead {36:36.5},{-114.65:-114.15}
    ;GreatLakes {41:49},{-92.5:-76} 
    region = "GreatLakes"
    BoxS = 41
    BoxN = 49
    BoxW = -92.5
    BoxE = -76
  
 
;---- Processing
   print("data processing")
;+++ loop
    lsm      = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat",0,dimsz, "integer")
    lsm      = addmeta(lsm,dimsz,(/"lat","lon"/),(/25,50,-125,-70/),"land sea mask"," ",-1,-1)

   do i = 0,ntime-1
    

   	pthin     = pth+yyyy(i)+"_all/"+yyyy(i)+sprinti("%0.2i", mm(i))+"/" 
   	;e.g. 2004_01_01_0215_skm.i.WisEmis_MERRA2          	
 		filename  = yyyy(i)+"_"+sprinti("%0.2i", mm(i))+"_"+sprinti("%0.2i", dd(i))+"_"+sprinti("%0.2i", hh(i))+mnt+"_"+skms(iskm)		
	    print(filename)
	    if (fileexists(pthin+filename)) then
            tmpdata := fbindirread(pthin+filename,0,dimsz, datatype) 
	        replace_ieeenan(tmpdata,UNDEF,0)
	        ;tmpdata = where(tmpdata.gt.220,tmpdata,UNDEF)
            tmpdata  = addmeta(tmpdata,dimsz,(/"lat","lon"/),geoinfo,longname,units,-1,-1)
        ;+++++ land sea mask
            if opt.eq."land" then
                tmpdata       = mask(tmpdata,lsm.eq.0,False)
            else if opt.eq."water" then
                tmpdata       = mask(tmpdata,lsm.ne.0,False)
            end if ; opt.eq."water"
            end if ; opt.eq."land"
        ;+++++ 
           tmpdata@_FillValue = UNDEF
            if i.eq.0 then
                tmp   = tmpdata({BoxS:BoxN},{BoxW:BoxE})
                nc    = dimsizes(tmp&lat); Number of Cross lines
                nd    = dimsizes(tmp&lon); Number of Down lines                   
                print("cross="+nc+" down="+nd)
                lat     = tmp&lat
                lon     = tmp&lon
                delete(tmp)
                LST  = new((/ntime,nc,nd/),datatype,UNDEF) 
            end if ;i.eq.0
	       LST(i,:,:)    = tmpdata({BoxS:BoxN},{BoxW:BoxE})
	    else
	       LST(i,:,:)    = UNDEF	 
	    end if;file exist	   
    end do;i
    delete(tmpdata)
    printVarSummary(LST)
    printMinMax(LST,True)
    
            mn      = dd
            sc      = dd
            mn      = 15
            sc      = 0

           
            tunits  =  "hours since 1-1-1 00:00:0.0"
            time    = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,tunits, 0)
            time!0  = "time"
            print(cd_calendar(time(0),0))
            printVarSummary(time)


            LST!0    = "time"
            LST&time = time
            LST!1    = "lat"
            LST&lat  = lat
            LST!2    = "lon"
            LST&lon  = lon

    if svdata  then
            print("Write NetCDF Data")
            vName   = "LST"
            fname = "./"+region+"."+vName+".UMD."+sat+".000.inst."+yyyymmddhh(0)+"."+yyyymmddhh(ntime-1)+".nc"
      
            print(fname)
           ;exit
            system("/bin/rm -f "+fname)
            fnc                 = addfile(fname,"c")
            
           
                        setfileoption(fnc,"DefineMode",True)
                        filAtt               = True
                        filAtt@title         = longname
                        filAtt@source_file   = "GOES-E datapool2"
                        filAtt@Conventions   = "None "
                        filAtt@creation_date = systemfunc("date")
                        filAtt@Created_by    = "Wen Chen, wchen122@umd.edu"
                        fileattdef( fnc, filAtt ) ; copy file attributes
                        dimUnlim = (/True, False, False/)
                        filedimdef(fnc,(/"time","lat","lon"/),(/-1,nc,nd/),dimUnlim)
                        filevardef(fnc,"time"    , typeof(time)    , getvardims(time))
                        filevardef(fnc,"lat"     , typeof(lat)     , getvardims(lat))
                        filevardef(fnc,"lon"     , typeof(lon)     , getvardims(lon))
                        filevardef(fnc, vName    , typeof(LST)      , getvardims(LST))
                        print(getfilevarnames(fnc))


                        filevarattdef(fnc,"time"      ,time)
                        filevarattdef(fnc,"lat"       ,lat)
                        filevarattdef(fnc,"lon"       ,lon)
                        filevarattdef(fnc,vName       ,LST)

                        setfileoption(fnc,"DefineMode",False)

                        fnc->time       = (/time/)
                        fnc->lat        = (/lat/)
                        fnc->lon        = (/lon/)
                        fnc->$vName$    = (/LST/)

             
            delete(fnc)
    end if ;svdata
      
 
;******************************************************
;						 Plotting
;******************************************************
	
;+++ MAP
if pltMap then 
	
	      pltpth    = "~/tmp/";"~/WORK/LST/"
	      wkstype   = "eps"
	      wksname   = "LST_"+sat+"_eg_"+region
	      lftstr    = wksname+units
	      rtstr     = cd_calendar(time(8775),0) 
	      tistr     = "" 
	      clim      = (/255,275,1/);(/285,300,1/);(/275,310,1/);(/245,305,1/);(/245,305,1/);
	      tmp       = LST(8775,:,:)
	     
	      delete(tmp@long_name)
	      delete(tmp@units)
	      print("Map Plotting")
          

   		wks = gsn_open_wks(wkstype, pltpth+"map_clim_"+wksname)
   		gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose a color map; MPL_jet
  		   ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); 

   		res                     = True
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
  
   		res@cnFillOn            = True            
   		;res@cnFillMode          = "RasterFill"        
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		res@cnLevelSelectionMode = "ManualLevels"   		
   		res@cnMinLevelValF       = clim(0)
   		res@cnMaxLevelValF       = clim(1)
         res@cnLevelSpacingF      = clim(2)
         
   		res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = 5
 
   		res@mpMinLatF             = min(tmp&lat);geoinfo(0)
   		res@mpMaxLatF             = max(tmp&lat);geoinfo(1)
   		res@mpMinLonF             = min(tmp&lon);geoinfo(2)
   		res@mpMaxLonF             = max(tmp&lon);geoinfo(3)
        
         res@mpDataSetName               = "Earth..4"
         res@mpDataBaseVersion           = "MediumRes";"HighRes";

         res@mpOutlineOn                 = True
         if watermask then
            res@cnFillDrawOrder             = "PreDraw"
            res@mpOceanFillColor            = "white"  
            res@mpLandFillColor             = "transparent"
            res@mpInlandWaterFillColor      = "white"
            
         end if   ;lsmask
         if landmask then
            res@cnFillDrawOrder             = "PreDraw"
            res@mpOceanFillColor            = "transparent"  
            res@mpLandFillColor             = "white"
            res@mpInlandWaterFillColor      = "transparent"
         end if   ;lsmask
         ;res@mpGeophysicalLineThicknessF = 2
         ;res@mpNationalLineThicknessF    = 2

   		res@mpOutlineBoundarySets = "USStates" ;"AllBoundaries" ;   ; "National" 
   		;res@gsnLeftStringOrthogonalPosF = -0.075
         ;res@gsnRightStringOrthogonalPosF = -0.075
         res@gsnLeftString  = lftstr
         res@gsnRightString = rtstr
        ;res@tiMainString   = tistr
   		plot=gsn_csm_contour_map(wks,tmp,res)
  		;draw(plot)
  		;frame(wks)
	end if

;+++ Histogram
	if pltHist then
	   print("Histogram Plotting")  
	   
      
  		wks = gsn_open_wks(wkstype, pltpth+"Hist_"+wksname)
  		;gsn_define_colormap(wks,"BlRe")
      ;gsn_define_colormap(wks,"ncview_default")
      gsn_define_colormap(wks,"BlGrYeOrReVi200")
  		res1 = True
      res1@gsnFrame                    = False
      res1@gsnDraw                     = False

      ;res1@gsnMaximize                 = True
      res1@gsnHistogramBarWidthPercent = 100

      ;res1@tmXBLabelStride             = 20
      ;res1@gsnHistogramNumberOfBins    = 20
      ;res1@gsnHistogramComputePercentages= True ;Missing Values included
      ;res1@gsnHistogramComputePercentagesNoMissing = True ;MissingValues excluded
      res1@tmXBMajorLengthF            = 0.01

      res1@tiXAxisString               = tihist
      res1@gsnHistogramMinMaxBinsOn    = False
      res1@tiYAxisOffsetXF             = 0.005
      res1@tiXAxisOffsetYF             = 0.005
      
      nbin  = toint((hists(1)-hists(0))/2.5+1)
      
      res1@gsnHistogramClassIntervals  = fspan(hists(0),hists(1),nbin)
      if histclm then
       
	      pct1=dimsizes(ndtooned(tmp))/100.
	      stats=stat_dispersion(ndtooned(tmp),False)
	      plot1=gsn_histogram(wks,ndtooned(tmp),res1)
	   else
	     
	      stats=stat_dispersion(ndtooned(data),False)
	      pct1=dimsizes(ndtooned(data))/100.
	      plot1=gsn_histogram(wks,ndtooned(data),res1)
	   end if  
  		tmYLLabels  = ispan(0,npct,1);(/0,1,2,3,4,5,6,7/);
      tmYLValues  = tmYLLabels*pct1;(/0,pct1,pct1*2,pct1*3,pct1*4,pct1*5,pct1*6,pct1*7/)
      
      getvalues plot1
            "tmXBLabels"             : tmXBLabels
            "tmXBValues"             : tmXBValues
            "tmYLLabelFontHeightF"   : fheight
      end getvalues       
      setvalues plot1              
                         "tmXBMode"  :   "Explicit"
                         "tmXBValues":   tmXBValues(::10)
                         "tmXBLabels":   tmXBLabels(::10)

                         "trYMaxF"   :   pct1*npct
                         "tmYLMode"  :   "Explicit"
                         "tmYLValues":   tmYLValues(::2)
                         "tmYLLabels":   tmYLLabels(::2)

                         "tmYROn"           :   False
                         "tiYAxisString"    : "Percent"
        end setvalues

        statstr = (/monstr(mon-1),\
                "Mean = "+sprintf("%.2f",stats(0)),\
                "Median = "+sprintf("%.2f",stats(8)),\
                "Min = "+ sprintf("%.2f",stats(2)),\
                "Max = "+sprintf("%.2f",stats(14))/)
                 print(statstr)
                 ntext = dimsizes(statstr)


            txres               = True
            txres@txFontHeightF = fheight
            txres@txJust        = "BottomLeft"

           

            xp              = tmXBValues(1)
            yp              = (npct-0.5)*pct1;(npct-1)*pct1
         dum1=gsn_add_text(wks,plot1,statstr(0),xp,0.9825*yp,txres)
         dum2=gsn_add_text(wks,plot1,statstr(1),xp,0.90*yp,txres)
         dum3=gsn_add_text(wks,plot1,statstr(2),xp,0.82*yp,txres)
         dum4=gsn_add_text(wks,plot1,statstr(3),xp,0.74*yp,txres)
         dum5=gsn_add_text(wks,plot1,statstr(4),xp,0.66*yp,txres)
	
		draw(plot1)
		frame(wks)
  		
	end if ;plt Hist
    ;print(tmXBValues)

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
