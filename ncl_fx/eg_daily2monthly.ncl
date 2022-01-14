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
load "$nclfx/addmeta.ncl"
begin
;**********************************************************
; For binary files 
; one record include one month of monthly or daily data 
;**********************************************************
 
;------ head
;+++ Parameters 
    vName    = "sdc" 
    Sat      = "MODIS"
    version  = "xiaolei"
    
    yyStrt   = 2002
    mmStrt   = 7
    ddStrt   = 1
    
     yyEnd    = 2010
     mmEnd    = 6
     ddEnd    = 30
    
	;mday  	 = (/31,28,31,30,31,30,31,31,30,31,30,31/ )

     Res   = 1
	nLat	 = 180
	nLon	 = 360
	
	geoinfo  = (/-89.75,89.75,-179.75,179.75/)
     Lat      = fspan(geoinfo(0),geoinfo(1),nLat)
     Lon      = fspan(geoinfo(2),geoinfo(3),nLon)


	pthin     	= "/data/pkgroup2/xiaolei/Level3/Result/"
	fname          = "daily_modis_sdc_200207_201006_gmt.dat"
	datatype       = "float"
	units	     = "W/^2"
	UNDEF          = -9999.

;+++ Flags   
     binFlag = True
	ncFlag  = False
     plotFlagMap = False
     mplsmask    = False
     mpchina     = False
  
;+++ Plot settings     
     wkstype     = "eps"
     wksname     = "test"
     
;+++ Start     
   

     ;+++ timestamp for binary data   
	 longname = "Daily_"+vName+"_of_"+Sat+version 
	 yyyymmdd = yyyymmdd_time(toint(yyStrt), toint(yyEnd), "integer")
	 tStrt    = toint(yyStrt*10000+mmStrt*100+ddStrt)
      tEnd     = toint(yyEnd*10000+mmEnd*100+ddEnd)
      print(tStrt+"-"+tEnd)
      TIME    = yyyymmdd({tStrt:tEnd})
      delete(yyyymmdd)
      year    = TIME/10000
      mmdd    = TIME-year*10000
      mm      = mmdd/100
      dd      = mmdd-mm*100
      
	 nrec	 = 0
  
     ;+++ input data
	ntime    = dimsizes(TIME)
	delete(TIME)
     dimsz    = (/ntime,nLat,nLon/)
	dimNames = (/"time","lat","lon"/)
     data     = new(dimsz,datatype,UNDEF)
      

           
          if fileexists(pthin+fname) then
               print(pthin+fname)
               data = fbindirread(pthin+fname,nrec,dimsz,datatype)  
          else
               data = UNDEF
          end if
          data = data(:,::-1,:)
     ;+++ add meta           
            hh      = mm
            mn      = mm
            sc      = mm           
            hh      = 0
            mn      = 0
            sc      = 0
            print(year+" "+mm+" "+dd)
            tunits  =  "days since 1800-01-01 00:00:00"  
            opt     = 0

            time    = cd_inv_calendar(year,mm,dd,hh,mn,sc,tunits, opt)
            time!0  = "time"
            print(time(0))
            printVarSummary(time)
            delete(opt)
     
          data    = addmeta(data,dimsz,dimNames,geoinfo,longname,units,time,-1)
          printVarSummary(data)
          printMinMax(data,True)
     
          opt = True
          opt@nval_crit = 12   ; require at least 12 values for the "avg" is calculated.
               
          dataMon = calculate_monthly_values (data, "avg", 0,opt)
          printVarSummary(dataMon)
          printMinMax(dataMon,True)
         ;printVarSummary(dataMon&time)

          tim = calendar_decode2(dataMon&time,2)
          indt= ind(tim.eq.20090701)  
          time0=200907        
         ;printVarSummary(tim)
         ;print(tim(84))
         tmp = dataMon(indt,:,:)
         printVarSummary(tmp)
         printMinMax(tmp,True)
          if binFlag then
               pathout   = "./";pthin
               ofname    = pathout+"s"+vName+"_MODISxiaolei_monthly_eg_200907.dat"
               fbindirwrite(ofname,tmp)
          end if

          if plotFlagMap then
                temp = tmp
                print("Plotting")
                wks = gsn_open_wks(wkstype, wksname)
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
                 res@cnLevelSpacingF      = 5
                 res@cnMinLevelValF       = 25
                 res@cnMaxLevelValF       = 350

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

                 res@gsnLeftString         = "MODIS(xiaolei) "+str_upper(vName)
             res@gsnRightString         = (time0/100)+"/"+sprinti("%0.2i",(time0-toint(time0/100)*100))

                plot=gsn_csm_contour_map_ce(wks,temp,res)
                ;draw(plot)
                ;frame(wks)
        end if

	
end
