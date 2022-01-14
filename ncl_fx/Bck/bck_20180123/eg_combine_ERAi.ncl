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
  Timst     = 197901
  Timed     = 201612
   
  outputFlag = True
     
   fils = systemfunc ("ls SRDF_*00-12*.nc") ; file paths
   fl   = addfiles (fils, "r")
   ListSetType (fl, "cat")        ; concatenate (=default)
   
   data0     = short2flt(fl[:]->$VarName$)
  
   printVarSummary(data0)
   print(data0@_FillValue)
   printMinMax(data0,True)
   delete(fils)
   delete(fl)
   
   fils = systemfunc ("ls SRDF_*12-24*.nc") ; file paths
   fl   = addfiles (fils, "r")
   ListSetType (fl, "cat")        ; concatenate (=default)
   
   data1     = short2flt(fl[:]->$VarName$)
  
   printVarSummary(data1)
   print(data1@_FillValue)
   printMinMax(data1,True)
   delete(fils)
   delete(fl)
   
    data=(data0+data1)/(2.0*86400.)
    data=where(data.lt.0.,data1@_FillValue,data)
    data=data(:,::-1,:)
   ;data=data0(:,::-1,:)
   printVarSummary(data)
   printMinMax(data,True)
   
   if (outputFlag) then
    ptho      = "/data/srb3/wchen/merge_cut_data/Zhang/" 
    ofilename = str_upper(VarName)+"_ERAi_1x1_Monthly_"+Timst+"-"+201612+".dat"
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

