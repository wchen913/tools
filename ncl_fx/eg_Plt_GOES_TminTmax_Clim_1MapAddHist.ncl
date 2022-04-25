load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/Map_plt_fx.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters 
   yrstrt   = 2004
   yrend    = 2009

	sat      = "GOES_E";"MOD11C1";
	vName    = "LST"
    ncVarName = "Tmax";"Tmin";
	opt 	= "land"
;+++ Flags
    landmask      = True
    watermask     = False
    
     pltMap        = True
    addHist        = False
 
  
;+++ Parameters	    
	nLat	 = 501
	nLon	 = 1101

	geoinfo  = (/25,50,-125.,-70/)
	dimsz	 = (/nLat,nLon/)
	dimNames = (/"lat","lon"/)
	datatype = "float"
	units	 = "(K)"
	nrec	 = 0
    UNDEF  = -999.
	 
				    
    pth         = "/data/srb2/wchen/LST/Diurnal/DTR_data_v1/"
    longname    =  str_upper(sat)+" "+ncVarName+" (UMD)" 
    monstr      = (/"JAN","FEB","MAR","APR","MAY","JUN",\
                    "JUL","AUG","SEP","OCT","NOV","DEC"/)
;+++ Plotting Path & file names & settings
	
	
	

	
;+++ Time Coverage
   yyyymmdd      = yyyymmdd_time(yrstrt,yrend,"integer")
   yyyy          = toint(yyyymmdd/10000)
   mmdd          = yyyymmdd-yyyy*10000
   mm            = toint(mmdd/100)
   dd            = mmdd-mm*100
   
   delete(mmdd)
   print("data input")
  ;print(yyyy(0)+" "+mm(0)+" "+dd(0)+" "+hh(23))
    
	if sat.eq."GOES_E" then
		infname = sat+"_"+vName+"_"+ncVarName+"_"+yrstrt+"-"+yrend+".nc"
	end if
	if sat.eq."MOD11C1" then
		infname = sat+"_"+ncVarName+"_"+yrstrt+"-"+yrend+".nc"
	end if
            print(pth+infname)
          
            fid                 = addfile(pth+infname,"r")
            datain                 = fid->$ncVarName$
            printVarSummary(datain)
            
                temp = new(dimsizes(datain),typeof(datain))
                temp = (/datain/)
                delete(datain)
                datain = addmeta(temp,dimsizes(temp),(/"time","lat","lon"/),(/25,50,-125,-70/),""," ",yyyymmdd,-1)
                if opt.eq."land" then
					datain = where(datain.ge.273,datain,UNDEF)
				end if 
				datain@_FillValue      = UNDEF
 
            printMinMax(datain,True)
            print(stddev(datain))

;---- Processing

 ;do mon=7,7;1,12

    mon   = 7;1;13;
	if mon.le.12 then
		inds  = ind(mm.eq.mon)
		data =  datain(inds,:,:)
		printVarSummary(data)
		printMinMax(data,True)      
		tmp      = dim_avg_n_Wrap(data,0)
		tstr     = sprinti("%0.2i", mon)
		printMinMax(tmp,True)      
        delete(data)
		delete(inds)
	  else
	  tmp      = dim_avg_n_Wrap(datain,0)
	  tstr     = "Annual"		 
	  end if 
	  data_clim = tmp
      delete(tmp)
      
	if opt.eq."land" then
           lsm      = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat",0,dimsizes(data_clim), "integer")
           lsm      = addmeta(lsm,dimsizes(data_clim),(/"lat","lon"/),(/25,50,-125,-70/),"land sea mask"," ",-1,-1)
           data_clim     = mask(data_clim,lsm.eq.0,False)   
    end if;opt
      
     
    
 


 
;******************************************************
;						 Plotting
;******************************************************
	
;+++ MAP
	if pltMap then
	
	      pltpth    =  "~/WORK/LST/Figures2/Lakes/Diurnal/";
	      wkstype   = "eps";"x11"; 
	      wksname   = sat+"_"+vName+"_"+ncVarName+"_clim_"+\
      yrstrt+"-"+yrend+"_"+sprinti("%0.2i", mon)
	      lftstr    = "Lake Huron"
 	      rtstr     = "";monstr(mon-1)
	      tistr     = ""
          if ncVarName.eq."Tmin" then
			if mon.eq.1 then
				clim      = (/274,277,1,1/)
				hists     = (/274,277,4,1/)
			end if
			if mon.eq.7 then
				clim      =(/286,292,1,1/)
				hists     = (/286,292,7,1/) 
			end if
			if mon.gt.12 then
				clim      =(/282,287,1,1/)
				hists     = (/282,287,6,1/)
			end if 
         end if
         if ncVarName.eq."Tmax" then
          if mon.eq.1 then
			clim      = (/274,277,1,1/)
			hists     = (/274,277,4,1/)
           end if
          if mon.eq.7 then
 	        clim      =(/286,292,1,1/)
				hists     = (/286,292,7,1/) 
           end if
		   if mon.gt.12 then
				clim      =(/282,287,1,1/)
				hists     = (/282,287,6,1/)
		end if 
         end if
         
	      
	      tmp   = data_clim({43:47},{-85:-79})
		  printMinMax(tmp,True)

	      delete(tmp@long_name)
	      delete(tmp@units)

          print("Map Plotting")
                  wks = gsn_open_wks(wkstype, pltpth+"map_"+wksname+"_addHist_"+opt)
                     gsn_define_colormap(wks,"MPL_autumn")
				 gsn_reverse_colormap(wks)
               ;if (mon.eq.7.or.mon.gt.12).and.(ncVarName.eq."DTR".or.ncVarName.eq."Tmin") then
					tmp = (/smth9(tmp,0.5,0.5,False)/)
				;end if
          		plot=Map_Plot_Region(wks,tmp,clim,opt,"MediumRes");"HighRes"

               
        getvalues plot
            "tmYLLabelFontHeightF"   : fheight
        end getvalues

    txres               = True
    txres@txFontHeightF = fheight*1.25
    txres@txJust        = "BottomLeft"
    txres@txFontColor   = "red"
    dum1=gsn_add_text(wks,plot,tstr,-84.75,43.25,txres)
    txres@txFontColor   = "Blue"
    dum2=gsn_add_text(wks,plot,ncVarName,-81,43.25,txres)
   
   draw(plot)

   		
   
;+++ Histogram
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
      tmp  = where(tmp.lt.hists(0)-1,UNDEF,tmp)
      tmp  = where(tmp.gt.hists(1)+1,UNDEF,tmp)

      histogram=gsn_histogram(wks,ndtooned(tmp),histres)

   end if;addHist
    frame(wks)
 
end if
    delete(tmp)
  ;send do ; mon  
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
