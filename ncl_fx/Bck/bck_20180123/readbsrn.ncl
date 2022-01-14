load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"

begin
pth_in  = "/aosc/ceop/Data/Ground_Data/BSRN/"
pth_out = "/data/crash/wchen/processed/Europe/"

year    = 2000:2014
month   = (/"01","02","03","04","05","06", "07","08","09","10","11","12"/)

stname  = (/"cab","cam","car","cnr","lin","ler","nya","pal","pay","son","tor"/)

nstn    = dimsizes(stname)
nyr     = dimsizes(year)
nmon    = dimsizes(month)

do ist=0,nstn-1
	do iyr=0,nyr-1
		yyyy=year(iyr)
		do imn=0,nmon-1
	        mm = month(imn)
			print(stname(ist)+" "+mm+" "+year)
		end do
	end do
end do
end
