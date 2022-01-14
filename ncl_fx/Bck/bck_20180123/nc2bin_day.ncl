load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"

begin
;*******************************
; specification and data put in 
;******************************* 
  VarName   = "A"
   
  outputFlag = True
     
  ;filelist  = systemfunc("ls /data/srb4/NAVEEN/modis/*day*.nc")
  filelist  = systemfunc("ls /data/crash/wchen/tmp/0001_max.nc")
  print(dimsizes(filelist))
  nfls      = dimsizes(filelist)
   
   do ifl = 0,nfls-1
   fsurffix  = get_file_suffix(filelist(ifl),0)
   fnbase    = fsurffix@fBase
   print(fnbase)
   fl        = addfile(filelist(ifl),"r")
  
 
   data      =  fl->$VarName$
   printVarSummary(data)
   print(data@_FillValue)
   printMinMax(data,True)
   ofilename = fnbase+".dat"
   print(ofilename)
   if (outputFlag) then 
    system("rm -f ./"+ofilename)
    fbindirwrite(ofilename,data)
   end if
   end do
  
   ;tmp = data(0,:,:)
   ;wks = gsn_open_wks("x11", "check")
   ;plot=gsn_csm_contour_map_ce(wks,tmp,False)
           
end


