
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
    vName    = "ssda"
   
    ORG      = "CFSR" 
    version  = "6hrAvg"
    dwnld    = "UCAR"; 
    
    RES      = 0.5     ;0.5;2;
    varName  = "DSWRF"
    nrecd    = toint(4)
    

    ncFlag   = True
   
 
       timeres  = "Daily"
       forecastt= "6Hour_Avg"
       pthin    = "/data/crash/wchen/NCEP_R2/"+timeres+"/"+forecastt+"/"+varName+"/"
       yyStrt   = 1983
       mmStrt   = 1
       ddStrt   = 1      

       yyEnd    = 2010
       mmEnd    = 12
       ddEnd    = 31


   
    
 do iyear   = yyStrt,yyEnd
        filelist = systemfunc("ls "+pthin+"*"+iyear+"*.nc")        
        fid      = addfiles(filelist,"r")
        ListSetType (fid, "cat")
        
        VarNames  = getfilevarnames(fid[0]) 
        indvar    = str_match_ind_ic(VarNames,varName)
        varname   = VarNames(indvar)
        print(varname)  
        datain  = fid[:]->$varname$
        printVarSummary(datain)
        printMinMax(datain,True)
        
;+++ extract daily average 
        tmp      = ndtooned(datain)
        ntime    = toint(dimsizes(datain&time))
        nlat     = dimsizes(datain&lat)
        nlon     = dimsizes(datain&lon)
        temp     = onedtond(tmp,(/ntime/nrecd,nrecd,nlat,nlon/))
 
        data_out  = dim_avg_n_Wrap(temp,1)
        printVarSummary(data_out)
        printMinMax(data_out,True)

exit
   if ncFlag then
		print("Write NetCDF Data")
		outpth	=  "/data/crash/wchen/NCEP_R2/"+timeres+"/"+forecastt+"/"+varName+"/"+"daily_avg/"
		ofname = varName+"."+ORG+"."+timeres+"."+iyear+".nc"
        print(outpth+ofname)
 exit
		 
		system("/bin/rm -f "+outpth+ofname)
    	fod     		=  addfile(outpth+ofname,"c")
        fod->lat  	    =  fid[0]->lat
		fod->lon  	    =  fid[0]->llon
		fod->time       =  fid[:]->ltime
   		fod->$varname$ 	=  data_out
   		delete(fod)
		delete(data_out) 
   end if
 end do

end
  

