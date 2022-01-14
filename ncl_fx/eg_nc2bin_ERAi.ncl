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
  VarName   = "strd"
   
  outputFlag = True
     
  filename  = "SRDF_ERAi_1x1_Monthly_00-12_197901-201512.nc"
  ;"SKT_ERAi_1x1_Monthly_197901-201512.nc"
  ;"TCW_ERAi_1x1_Monthly_197901-201512.nc"
  ;"CC_ERAi_1x1_Monthly_197901-201512.nc"
  ;"10UV_ERAi_1x1_Monthly_197901-201512.nc"
  print(filename)   

   fl       = addfile(filename,"r") 
   data0     = short2flt(fl->$VarName$)
  
   printVarSummary(data0)
   print(data0@_FillValue)
   printMinMax(data0,True)
   delete(fl)
   filename  = "SRDF_ERAi_1x1_Monthly_12-24_197901-201512.nc"
  ;"TCW_ERAi_1x1_Monthly_197901-201512.nc"
  ;"CC_ERAi_1x1_Monthly_197901-201512.nc"
  ;"10UV_ERAi_1x1_Monthly_197901-201512.nc"
  print(filename)   

   fl       = addfile(filename,"r") 
   data1     = short2flt(fl->$VarName$)
  
   printVarSummary(data1)
   print(data1@_FillValue)
   printMinMax(data1,True)
   
   data=(data0+data1)/(2.0*86400.)
   data=where(data.lt.0.,data1@_FillValue,data)
   data=data(:,::-1,:)
   printVarSummary(data)
   printMinMax(data,True)
   
   if (outputFlag) then
    ptho      = "/data/srb3/wchen/merge_cut_data/Zhang/" 
    ofilename = str_upper(VarName)+"_ERAi_1x1_Monthly_197901-201512.dat"
    print(ptho+ofilename)
    system("rm -f "+ptho+ofilename)
    fbindirwrite(ptho+ofilename,data)
   end if

  
   ;tmp = data(0,:,:)
   ;wks = gsn_open_wks("x11", "check")
   ;plot=gsn_csm_contour_map_ce(wks,tmp,False)
           
end
; fsurffix  = get_file_suffix(filename(ifl),0)
; fnbase    = fsurffix@fBase
; print(fnbase)

