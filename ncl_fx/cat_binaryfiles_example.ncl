load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$nclfx/addmeta.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters   
	nhour 	 = 24 
	nday  	 = 31 
	nLat	 = 501
	nLon	 = 1101
	geoinfo  = (/25,50,-125.,-70/)
	dimsz	 = (/nday,nhour,nLat,nLon/)
	 
	datatype = "float"
	units	 = "(K)"
    yy       = "00"

    ;mm       = "03" 	jdays    = 60 	jdaye    = 90
    ;mm       = "05"  	jdays    = 121 	jdaye    = 151
	;mm       = "06" 	jdays    = 152 	jdaye    = 181
	;mm       = "07" 	jdays    = 182	jdaye    = 212
	;mm       = "08" 	jdays    = 213		jdaye    = 243
	mm       = "12"
 	jdays    = 335
	jdaye    = 365
    mnt      = 15
    nrec	 = 0

    pthin     	= "/data/srb3/wchen/LST/Chris/scr_east/"
    data      	= new(dimsz,datatype)
    data@_FillValue= -9999.
    outputFlag 	= True
    do jday=jdays,jdaye
	   mday=jday-jdays
    	do hour=0,nhour-1
    		filename  = pthin+"LST_2000"+sprinti("%0.3i",jday)+"_"+sprinti("%0.2i",hour)+mnt+".dat"
 			print(filename)
    		if (fileexists(filename)) then
				 data(mday,hour,:,:)=fbindirread(filename,nrec, (/nLat,nLon/),datatype)
				 ;printMinMax(data(mday,hour,:,:),True)				 
			else
				 data(mday,hour,:,:)=-9999.
  			end if
		end do
    end do
	printMinMax(data,True)
	;printVarSummary(data)
	if (outputFlag) then
    	ofilename = pthin+"ALXI"+"_"+yy+mm+".dat"
    	print(ofilename)
    	system("rm -f ../"+ofilename)
    	fbindirwrite(ofilename,data)
    	system("ls "+ pthin+"ALXI*.dat")
   end if

end
