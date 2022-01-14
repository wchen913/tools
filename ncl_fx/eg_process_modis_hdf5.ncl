load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/data/srb1/wchen/tools/ncl_fx/substring.ncl"
load "/data/srb1/wchen/tools/ncl_fx/addmeta.ncl"
begin
;*******************************
; specification and data put in 
;******************************* 
   yrstr=2004  
   ndays=366
   nhrs = 24 
   fpath="/data/srb3/wchen/Satellite/MODIS/monthly/MOD11C3/"
  ;filename=fpath+"MOD11C3.A2004001.006.2015213011324.hdf"
   fils = systemfunc ("ls "+fpath+"MOD11C3.A"+yrstr+"*.hdf") ; file paths
   print(fils)
   nfls = dimsizes(fils)
  ;print(nfls)
   Res=0.05
        

    dimNames=(/"lat","lon"/)
    geoinfo=(/-89.5,89.5,-179.5,179.5/)
    longname="Monthly daytime 3min CMG Land-surface Temperature"
    
    stpth   = "/data/srb2/wchen/LST/SURFRAD_obtained/"
    StLon = (/-116.018,-88.37,-89.97,-105.10,-105.237,-77.93,-96.62/)
    StLat = (/  36.626, 40.06, 34.25,  48.31,  40.125, 40.72, 43.73/)
    stid  = (/   "dra", "bon", "gwn",  "fpk",   "tbl", "psu", "sxf"/)
    
    modis_st = new((/nfls,dimsizes(StLon)/),"float",0)
    stdata   = new(ndays*nhrs,"float",0)
    pltpth   = "~/WORK/LST/";
    
    time    = yyyymmdd_time(yrstr,yrstr,"integer")
    year    = time/10000
    mmdd    = time-year*10000
    mm      = mmdd/100
    dd      = mmdd-mm*100
    print(dd(0)+ " "+ mm(0)+" "+ year(0))
    delete(time)
    delete(mmdd)
    hh      = dd
    mn      = dd
    sc      = dd


    hh      = 12
    mn      = 0
    sc      = 0
    tunits  =  "days since 1977-01-1 12:00:00" ;"months from 1-1-1"
    opt     = 0

    time    = cd_inv_calendar(year,mm,dd,hh,mn,sc,tunits, opt)
    time!0  = "time"
    print(time(0))
    delete(year)
    delete(mm)
    delete(dd)
    delete(hh)
    delete(mn)
    delete(sc)
    delete(opt)
   do iSt = 1,1
   
    stfname = yrstr+"_LST_SURFRAD_"+str_upper(stid(iSt))+"_day.dat"    
    stdata  = fbindirread(stpth+stfname,0,ndays*nhrs,"float")    
    stdata  = where(stdata.gt.0,stdata,0)
    stdata@_FillValue=0
    printMinMax(stdata,True)
    tmp     = onedtond(stdata,(/ndays,nhrs/))
    tmp(:,0:14)=0
    tmp(:,20:23)=0
    stdata  = ndtooned(tmp)
    delete(tmp)
    stdata@_FillValue=0
    stdata!0="time"
    stdata&time=time
    
    opt = True
    opt@nval_crit = 12
    stdd = calculate_daily_values (stdata, "avg", 0, opt)
   

  
    do ifl=0,0;nfls-1
        filename=fils(ifl)
        print(filename)
    
        setfileoption("hdf", "FileStructure", "Advanced")
        f = addfile(filename, "r")
        ;print(f)
        lstd = short2flt(f->LST_Day_CMG)
       ;printVarSummary(lstd)
         
        qcd  = getbitsone(f->QC_Day)
       ;printVarSummary(qcd)
        dvt  = f->Day_view_time
       ;printVarSummary(dvt)
          qcd!0 = "lat"
          qcd!1 = "lon"
        
        
        dimsz=dimsizes(lstd)
        lstd=lstd(::-1,:)
        lstd= addmeta(lstd,dimsz,dimNames,geoinfo,longname,lstd@units,-1,-1)
        printVarSummary(lstd)
        printMinMax(lstd,True)
        Lat=lstd&lat
        Lon=lstd&lon
        indlat  = ind(Lat.ge.StLat(iSt)-Res.and.Lat.le.StLat(iSt)+Res)
        indlon  = ind(Lon.ge.StLon(iSt)-Res.and.Lon.le.StLon(iSt)+Res)
        if (.not.all(ismissing(indlat)) ).and.(.not.all(ismissing(indlon))) then
            print(Lat(indlat))
            print(Lon(indlon))
            print(qcd(indlat,indlon,:))
            print(dvt(indlat,indlon))
            tmp = new((/dimsizes(indlat),dimsizes(indlon)/),typeof(lstd),0)
            print("extract data")

            do itlat = 0,dimsizes(indlat)-1
            do itlon = 0,dimsizes(indlon)-1
                tmp(itlat,itlon)=lstd(indlat(itlat),indlon(itlon))
            end do ;do itlon
            end do  ;do itlat
           
            if (dimsizes(indlat).gt.1).or.(dimsizes(indlon).gt.1) then
                rad         = 4.0*atan(1.0)/180.0
                wgty        = cos(Lat(indlat)*rad)
                temp        = wgt_areaave_Wrap(tmp,wgty,1.0,0)
                delete(wgty)
                delete(tmp)
                tmp         = temp
                delete(temp)
            end if ;dimsizes(indlat)
            modis_st(ifl,iSt)=tmp
            delete(tmp)
           ;print(modis_st(ifl,iSt))
         else
                print("Can not find grid near Site")
                exit
         end if ;if (.not.all(ismissing(indlat)) )
         delete(indlat)
         delete(indlon)

       
       ;wks = gsn_open_wks("x11", "test") 
       ;plot=gsn_csm_contour_map(wks,lstd(::10,::10),False)  
    end do ;ifl 
    print(modis_st(:,iSt))
    end do ;iSt
end

