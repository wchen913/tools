load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;*******************************
; specification and data put in 
;*******************************    
   
  
   
 setfileoption("h5", "FileStructure", "Advanced")

 fn = "MOD21_L2.A2000065.0030.006.2014089204734.h5"

 fi = addfile(fn, "r")

printVarSummary(fi);print(fi)
     
           
end

