load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;*******************************
; For binary files 
;*******************************    
  path  = "lst10.dat"
  nlat  = 501
  nlon  = 1011
  nrec  = 0
  dims  = (/501,1011/)
  lst10 = fbindirread(path, nrec, dims, "float")
         
end

