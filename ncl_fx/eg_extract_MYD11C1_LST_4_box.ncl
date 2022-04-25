load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/data/srb1/wchen/tools/ncl_fx/substring.ncl"
load "/data/srb1/wchen/tools/ncl_fx/addmeta.ncl"
;---------------------------------------;
; Box Plot for LST comparisions         ;
; For values and multi-year average only;
;---------------------------------------;
begin
;*******************************
; specification and data put in 
;******************************* 
   SatStr = "MYD11C1"  
   version= "006"
   Region = "LakeHuron"
   yrstr = 2004  
   yrend = 2009

   ymd      = yyyymmdd_time(yrstr,yrend,"integer")
   ntime    = dimsizes(ymd)
 
   ;filename=fpath+"MOD11C1.A2006343.006.2015306231406.hdf"
   fpath="/data/srb3/wchen/Satellite/MODIS/"+SatStr+"/"

   
    Res=0.05 
    UNDEF = -999.
    dimNames=(/"time","lat","lon"/)
   ;geoinfo=(/-89.5,89.5,-179.5,179.5/)
   ;geoinfo=(/-89.95,90,-180,179.95/)
    geoinfo=(/-90,90,-180,179.95/)

    longname="Daily CMG Land-surface Temperature, "+version
    
    svdata   = True;False;
    lon=fspan(geoinfo(2),geoinfo(3),7200)
    lat=latGlobeFo(3600,"lat","latitude","degree_north")
    
    lst = new((/ntime,2,81,121/),"float",UNDEF) 
    lst = UNDEF
    
    do idy = 0,ntime-1
         yyyymmdd      = ymd(idy)
         yyyy          = toint(yyyymmdd/10000)
         mmdd          = yyyymmdd-yyyy*10000
         mm            = toint(mmdd/100)
         dd            = mmdd-mm*100
         doy           = day_of_year(yyyy,mm,dd)
         print(yyyy+"   "+mm+"  "+dd+" / "+doy) 

         print("***** read in MODIS data *****")
         filename = systemfunc ("ls "+fpath+SatStr+".A"+yyyy+sprinti("%0.3i", doy)+"."+version+"*.hdf")
         if .not.all(ismissing(filename)) then
            print(filename)            
            setfileoption("hdf", "FileStructure", "Advanced")
            f = addfile(filename, "r")
           ;print(f)

              
            lstd = short2flt(f->LST_Day_CMG(::-1,:)) 
            lstd = where(lstd.ne.0,lstd,UNDEF)
            lstd@_FillValue = UNDEF
            lstd!0 = "lat"
            lstd&lat = lat
            lstd!1 = "lon"
            lstd&lon = lon            
            printVarSummary(lstd) 
            printMinMax(lstd,True)     
           
            lstn = short2flt(f->LST_Night_CMG(::-1,:))
            lstn = where(lstn.ne.0,lstn,UNDEF)
            lstn@_FillValue = UNDEF
            copy_VarMeta(lstd,lstn)  
            printVarSummary(lstn) 
            printMinMax(lstn,True) 
              
            tmpd = lstd({25:50.025},{-125:-70})
            tmpn = lstn({25:50.025},{-125:-70})
			tmpd&lat  = fspan(25,50,501)
			tmpn&lat  = tmpd&lat
			lst(idy,0,:,:) = (/tmpd({43:47},{-85:-79})/)
			lst(idy,1,:,:) = (/tmpn({43:47},{-85:-79})/)
			delete(lstd)
			delete(lstn)
			delete(tmpd)
			delete(tmpn)
         end if;ismissing

    
     end do ;idy     
 
      lst!0 ="ymd"
	  lst&ymd = tofloat(ymd)
	  lst!1 = "dynt"
	  lst&dynt = (/0,1/);0--day;1--night
	  lst!2	= "lat"
	  lst&lat = fspan(43,47,81)
	  lst!3   = "lon"
	  lst&lon = fspan(-85,-79,121)
	  printVarSummary(lst)
	  printMinMax(lst,True)
;;;;;;;;;;;; output ;;;;;;;;;;;;;;;;
    if svdata then 
        print("Write NetCDF Data")
            ;------
            fname = SatStr+".LST.dynt."+ymd(0)+"."+ymd(ntime-1)+"."+Region+".nc"

            print(fname)
           ;exit
            system("/bin/rm -f "+fname)
           setfileoption("nc","Format","NetCDF4Classic")
            fod                 = addfile(fname,"c")
           
            fod->lst             = lst
            delete(fod)
           
    end if ;svdata
 

  
end      
