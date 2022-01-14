load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$nclfx/addmeta.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
	vName		= "ssda"
    yyyymmStrt	= 198307
    yyyymmEnd   = 201412

    ntim  	 = 378 	
	nLat	 = 180
	nLon	 = 360
    UNDEF 	 = -9999.

	geoinfo  = (/-89.5,89.5,-179.5,179.5/)
	dimsz	 = (/ntim,nLat,nLon/)
	dimNames = (/"time","lat","lon"/)
	datatype = "float"
	units	 = "(W/M^2)"
	nrec	 = 0

    plotFlagMap = False
    binFlag  = False
    ncFlag   = True

    wkstype="x11"
	wksname="test"
	
	pthin     = "/data/crash/wchen/merge_cut_data/"
 	filename  = pthin+"mon_noamsat_biascorrected_dx_modis_sda_198307_201412_new1.dat"
	longname  = "UMD surface shortwave downdward flux, all sky"
;+++ Time Stamps
        yyyymm 	= yyyymm_time(1983, 2014, "integer")
		;print(yyyymm)
        indts   = ind(yyyymm.eq.yyyymmStrt)
        indte	= ind(yyyymm.eq.yyyymmEnd)
		time    = yyyymm(indts:indte)
;+++ Read Data   		
 		print(filename)
	    data = new(dimsz,datatype,UNDEF)
	    data = fbindirread(filename,0,dimsz, datatype)
	    printMinMax(data,True)
        data = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
		printVarSummary(data)
        
        tmp = data(:,{29.5:62.5},{-14.5:40.5});Europe
       ;tmp = data(:,{19.5:60.5},{-170.5:-109.5});Liu from PNL
		printVarSummary(tmp)
	    printMinMax(tmp,True)
        print(dimsizes(tmp))
;+++ Write Data
		if binFlag then			
			pathout		= pthin
           ;ofname      = pathout+"ssda_monthly_20N60N_170W110W_198307_201412.dat"
			ofname      = pathout+"ssda_monthly_Europe_"+yyyymmStrt+"_"+yyyymmEnd+".dat"
			fbindirwrite(ofname,tmp)
		end if
		if ncFlag then
			nlat 	= dimsizes(tmp&lat)
			nlon	= dimsizes(tmp&lon)
			lat		= tmp&lat
			lon		= tmp&lon
			printVarSummary(lat)
			printVarSummary(lon)
			printVarSummary(time)
            year    = time/100
			mm      = time-year*100
            delete(time)
            dd      = mm
            hh      = mm
            mn      = mm
            sc      = mm

            dd     	= 1            
            hh     	= 12
            mn      = 0
            sc      = 0
            print(year+" "+mm+" "+dd)
            tunits  =  "days since 1977-01-1 12:00:00" ;"months from 1-1-1"
            opt     = 0
             
            time    = cd_inv_calendar(year,mm,dd,hh,mn,sc,tunits, opt)
  			time!0  = "time"
  			print(time(0))
            printVarSummary(time)
            delete(tmp&time)
            tmp&time = time
            printVarSummary(tmp)

			outpth		= pthin
			ofname      = "ssda_monthly_Europe_"+yyyymmStrt+"_"+yyyymmEnd+".nc"
			system("/bin/rm -f "+outpth+ofname)
			fnc         =addfile(outpth+ofname,"c")

			setfileoption(fnc,"DefineMode",True)
 			filAtt               = True
 			filAtt@title         = longname
 			filAtt@source_file   = "None "
 			filAtt@Conventions   = "None "  
 			filAtt@creation_date = systemfunc("date")
 			fileattdef( fnc, filAtt ) ; copy file attributes                    
 			dimUnlim = (/True, False, False/)  
 			filedimdef(fnc,(/"time","lat","lon"/),(/-1,nlat,nlon/),dimUnlim)
			filevardef(fnc,"time"    , typeof(time)    , getvardims(time))
 			filevardef(fnc,"lat"     , typeof(lat)     , getvardims(lat)) 
 			filevardef(fnc,"lon"     , typeof(lon)     , getvardims(lon))
 			filevardef(fnc, vName    , typeof(tmp)      , getvardims(tmp))
			print(getfilevarnames(fnc)) 

            
  			filevarattdef(fnc,"time"      ,time)
  			filevarattdef(fnc,"lat"       ,lat)                     
  			filevarattdef(fnc,"lon"       ,lon)                
  			filevarattdef(fnc,vName       ,tmp)
        
  			setfileoption(fnc,"DefineMode",False)

  			fnc->time       = (/time/)  			
  			fnc->lat        = (/lat/)
  			fnc->lon        = (/lon/)
  			fnc->$vName$    = (/tmp/)
		end if
;+++ MAP
	if plotFlagMap then
		print("Plotting")
   		wks = gsn_open_wks(wkstype, wksname)
   		gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose a color map; MPL_jet
  		;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); 

   		res                     = True
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = False            
   		res@cnFillMode          = "RasterFill"        
   		res@cnLinesOn           = True            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = True

   		;res@cnLevelSelectionMode = "ManualLevels"
   		;res@cnLevelSpacingF      = 1;2.5;5
   		;res@cnMinLevelValF       = minT
   		;res@cnMaxLevelValF       = maxT 

   		res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = 5
 
   		res@mpMinLatF             = tmp&lat(0)
   		res@mpMaxLatF             = tmp&lat(dimsizes(tmp&lat)-1)
   		res@mpMinLonF             = tmp&lon(0)
   		res@mpMaxLonF             = tmp&lon(dimsizes(tmp&lon)-1)
         
		; turn on state boundaries; " USStates" ; "National" 
   		res@mpOutlineBoundarySets = "AllBoundaries"    
                                                  
   		;res@gsnLeftString         = ""
  	    ;res@tiMainString          = ""
    
   		plot=gsn_csm_contour_map(wks,tmp(0,:,:),res)
  		;draw(plot)
  		;frame(wks)
	end if


end

