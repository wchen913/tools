load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;*******************************
; specification and data put in 
;*******************************    
   
  
  a =  addfile("/aosc/helios3/cli/ERAi/data/nc/ei.mdfa.fc12hr.sfc.regn128sc.2010120100.li16629.nc","r")
  b = addfile("/data/crash/wchen/ERA_Interim/Monthly_Mean/12_Forecast//SSRD/ei.mdfa.fc12hr.sfc.regn128sc.2010120100.SSRD.nc" ,"r")
 
   ; print(a)
  
   ; print(b)
   data1 = a->SSRD_GDS4_SFC_120 
   data2 = b->SSRD_GDS4_SFC_120 
   diff  = data2-data1  
   printMinMax(diff,True)
end

