load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
;This function is to add meta info to the data
undef("addmeta")
function addmeta(data:numeric,\
					 dimsz:numeric,\
					 dimnames:string,\
					 geoinfo[4]:numeric,\
                     longname:string,\
                     units:string,
					 opttime,optlev)
local ndims,idim,lat,lon,lev,time,latL1,latL2,lonL1,lonL2,day,hour
begin
;****************************

latL1=geoinfo(0) ;geoinfo(0): lat limit1
latL2=geoinfo(1) ;geoinfo(1): lat limit2
lonL1=geoinfo(2) ;geoinfo(2): lon  limit1
lonL2=geoinfo(3) ;geoinfo(3): lon  limit2
opttime@_FillValue=-1 
optlev@_FillValue=-1

data@long_name=longname
data@units=units
ndims=dimsizes(dimsz)
if ndims.lt.1 then
	print("ndims must ge 1")
	exit()
else if ndims.eq.1
   if isStrSubset("time",dimnames) then
   		time=opttime
   		time@long_name="time"
   		time!0="time"
   		time&time=time

   		data!0="time"
   		data&time=time
 	else if isStrSubset("latitude",dimnames) then
        if (latL1 .gt.latL2) then
         	print("the lat must degree north")
            exit()
        end if
   		lat=fspan ( latL1,latL2 ,dimsz)        
   		lat!0="lat"
   		lat&lat=lat
   		lat@long_name="latitude"        
        lat@units="degree_north"

   		data!0="lat"
   		data&lat=lat
 	else if isStrSubset("longitude",dimnames) then 
        if(lonL1.gt.lonL2) then
        	print("the lon must degree east")
            exit()
        end if  
   		lon=fspan(lonL1,lonL2,dimsz)
   		lon!0="lon"
   		lon&lon=lon
   		lon@long_name = "longitude"
        lon@units     = "degree_east"

   		data!0="lon"
   		data&lon=lon
 	else if isStrSubset("level",dimnames) then   
   		lev =optlev
   		lev!0="lev"
   		lev&lev=lev
   		lev@long_name= "level"

   		data!0="lev"
   		data&lev=lev
    else if isStrSubset("days",dimnames) then
        day=ispan(1, dimsz,1)
        day!0="day"
        day&day=day

        data!0 = "day"
        data&day=day
    else if isStrSubset("hours",dimnames) then
        hour=ispan(0,dimsz-1,1)
        hour!0="hour"
        hour&hour=hour

        data!0="hour"
        data&hour=hour
    end if
    end if
 	end if
    end if
    end if
    end if
else if ndims.gt.1 .and. ndims.le.4
	do idim=0,ndims-1
 		if isStrSubset("time",dimnames(idim)) then
   			time=opttime
   			time@long_name="time"
   			time!0="time"
   			time&time=time

   			data!idim="time"
   			data&time=time 
 		else if isStrSubset("latitude",dimnames(idim)) then
			if (latL1.gt.latL2) then
         		print("the lat must degree north")
            	exit()
            end if
   			lat=fspan ( latL1,latL2 ,dimsz(idim))
   			lat!0="lat"
   			lat&lat=lat
   			lat@long_name="latitude"
        	lat@units="degree_north"

   			data!idim="lat"
   			data&lat=lat
 		else if isStrSubset("longitude",dimnames(idim)) then
			if(lonL1.gt.lonL2) then
        		print("the lon must degree east")
            	exit()
        	end if  
   			lon=fspan(lonL1,lonL2,dimsz(idim))
   			lon!0="lon"
   			lon&lon=lon
   			lon@long_name = "longitude"
			lon@units     = "degree_east"   

   			data!idim="lon"
   			data&lon=lon
 		else if isStrSubset("level",dimnames(idim)) then 
   			lev =optlev
   			lev!0="lev"
   			lev&lev=lev
   			lev@long_name= "level"

   			data!idim="lev"
		    data&lev=lev
		else if isStrSubset("days",dimnames(idim)) then
        	day=ispan(1, dimsz(idim),1)
        	day!0="day"
        	day&day=day

        	data!idim = "day"
        	data&day=day
    	else if isStrSubset("hours",dimnames(idim)) then
        	hour=ispan(0,dimsz(idim)-1,1)
        	hour!0="hour"
        	hour&hour=hour

        	data!idim="hour"
        	data&hour=hour
    	end if
    	end if      
	 	end if
        end if
        end if
        end if
	end do
else
print("ndim gt 4, not define yet")
end if
end if
end if
return(data)
;****************************
end




