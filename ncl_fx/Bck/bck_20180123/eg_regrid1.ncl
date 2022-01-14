
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
    vName    = "USLW"
   
    ORG      = "" 
    version  = ""
    src      = "" 
    datatype = "float"
    UNDEF    = -999.0
    ntime    = 96
    
    orgRES  = 0.25; 
    nLon    = 1440
    nLat    = 720
    orgLat  = fspan(-90,89.75,nLat) 
    orgLon  = fspan(0,359.75,nLon)
              
    objRES  = 1;
    objlat  = fspan(-89.5,89.5,180)
    objlon  = fspan(-179.5,179.5,360)
    varName = ""
    
    binFlag = True
    ncFlag  = False

    timeStep = "mon"; "mon"; "day"

;+++ Path & Setting time period +++
    if timeStep .eq."mon" then
       timeres  = "Monthly_Mean"   
       pthin    = "/data/pkgroup3/zhang/USLW/USLW_cli/"      
       yyStrt   = 2003
       mmStrt   = 1
       ddStrt   = 1
       yyEnd    = 2010
       mmEnd    = 12
       ddEnd    = 31
       nrec     = 0
       ndim     = (/ntime,nLat,nLon/)
    end if
      
	if timeStep.eq."day" then
       timeres  = "Daily_Mean"
       fname    = ""
       pthin    = ""
       yyStrt   = 2003
       mmStrt   = 1
       ddStrt   = 1      

       yyEnd    = 2010
       mmEnd    = 12
       ddEnd    = 31
    end if

     
               
      if timeStep .eq."day" then
        ymds = yyStrt*10000+mmStrt*100+ddStrt
        ymde = yyEnd*10000+mmEnd*100+ddEnd 
        filelist  = systemfunc("ls "+pthin+".dat")        
        fid       = addfiles(filelist,"r")       
      end if
      
      if timeStep .eq."mon" then      
        ymds = yyStrt*10000+mmStrt*100
        ymde = yyEnd*10000+mmEnd*100+ddEnd 
        filename  = "uslw_mon_2003_2010.dat"
        datain = fbindirread(pthin+filename,nrec,ndim,datatype)
        TIME   = yyyymm_time(yyStrt, yyEnd, "integer")
      end if
   
;+++ cut data period
      tmplon  = orgLon
      tmplon(0:nLon/2-1)    = orgLon(nLon/2:nLon-1)-360.
      tmplon(nLon/2:nLon-1) = orgLon(0:nLon/2-1)
      delete(orgLon)
      orgLon = tmplon
      delete(tmplon)
      
      tmpdata  = datain(:,:,:) 
      tmpdata(:,:,0:nLon/2-1)    = datain(:,:,nLon/2:nLon-1) 
      tmpdata(:,:,nLon/2:nLon-1) = datain(:,:,0:nLon/2-1)
      delete(datain)
      data     = tmpdata
      delete(tmpdata)
      
      data@_FillValue = UNDEF
      data!0    = "time"
      data!1    = "lat"
      data&lat  = orgLat
      data!2    = "lon"
      data&lon  = orgLon         
      data&time = TIME          
      printVarSummary(data)
      printMinMax(data,True)
      
      data_out = linint2_Wrap(data&lon,data&lat,data,True,objlon,objlat,0)
      printVarSummary(data_out)
      printMinMax(data_out,True)
      
	if binFlag then
       pthout = "/data/srb1/wchen/WORK/others/Zhang/regrid/"
       ofname = str_lower(vName)+"_"+timeStep+"_"+yyStrt+"_"+yyEnd+"_1x1.dat"
    	print(pthout+ofname)
    	system("rm -f ../"+pthout+ofname)
    	fbindirwrite(pthout+ofname,data_out)
    	
   end if
   if ncFlag then
		print("Write NetCDF Data")
		
   end if

end
  ;VarNames  = getfilevarnames(fl[0])
  ;print(VarNames)
  ;indvar    = str_match_ind_ic(VarNames,VarName)

 ;print(fid[0])
       ;print(fid[0]->initial_time0_encoded)
       ;print(fid[0]->initial_time0)

  ;print(indvar)

  ;data      =  fl[:]->$VarNames(indvar)$
       ;printVarSummary(LatGS)
       ;printVarSummary(LonGS)
       ;printVarSummary(datain)
       ;print(temp(0,0,113,256)+" "+temp(0,1,113,256))
       ;+++ Regridding +++ Gauss Grid-> Fixed Grid
;  if regridFlag then
;     nLon    = 360
;     nLat    = 180
;     Lat     = fspan(89.5,-89.5,nLat);(/89.5,-89.5/)
;     Lon     = fspan(0.5,359.5,nLon) ;(/0.5,359.5/)
  
;      tmp    = linint2_Wrap(datain&lon,datain&lat,datain,True,Lon,Lat,0)      
;      delete(datain)
 ;     datain = tmp
 ;     delete(tmp)
   ;"OK here"  
      
;*** Conver Lat N-S to S-N
 ;      Lat      = Lat(::-1)
 ;      datain   = datain(:,::-1,:)
;*** Conver Lon 0~360E to -180W-180E
 ;      Lon      = (/Lon-180.0/)  
 ;      nLon     = dimsizes(Lon)
 ;      indLon1  = toint(nLon/2)
 ;      tmp      = datain
 ;      tmp(:,:,0:indLon1-1)     = datain(:,:,indLon1:nLon-1)
 ;      tmp(:,:,indLon1:nLon-1)  = datain(:,:,0:indLon1-1)
 ;      data     = tmp
 ;      data&LON = (/Lon/)
 ;      delete(tmp)
 ;      delete(datain) 
 ;    else
 ;    end if

