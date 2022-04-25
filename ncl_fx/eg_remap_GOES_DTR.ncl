load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/Map_plt_fx.ncl"
load "$nclfx/Hist_plt_fx.ncl"
begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters 
yrstrt = 2004
yrend = 2009
pth = "/data/srb2/wchen/LST/Diurnal/Bck/DTR_data_v1/"
sat = "GOES_E"
vName = "LST"
ncVarName = "DTR"
opt = "water"
version = "v1"
;+++ Flags
rgrd = True
svdata = True
optplt = False
;+++ Parameters	    
nLat = 501
nLon = 1101

geoinfo = (/25,50,-125.,-70/)
dimsz	= (/nLat,nLon/)
dimNames = (/"lat","lon"/)
datatype = "float"
units	= "(K)"
nrec	= 0
UNDEF = -999.
	 
longname =  str_upper(sat)+" "+ncVarName+" (UMD)" 
monstr = (/"JAN","FEB","MAR","APR","MAY","JUN",\
                    "JUL","AUG","SEP","OCT","NOV","DEC"/)

;+++ Time Coverage
yyyymmdd = yyyymmdd_time(yrstrt,yrend,"integer")
yyyy = toint(yyyymmdd/10000)
mmdd = yyyymmdd-yyyy*10000
mm = toint(mmdd/100)
dd = mmdd-mm*100

delete(mmdd)
print("data input")
;print(yyyy(0)+" "+mm(0)+" "+dd(0)+" "+hh(23))
	
if sat.eq."GOES_E" then
	infname = sat+"_"+vName+"_"+ncVarName+"_"+yrstrt+"-"+yrend+".nc"
end if

fid                 = addfile(pth+infname,"r")
datain                 = fid->$ncVarName$
printVarSummary(datain)
				
temp = new(dimsizes(datain),typeof(datain))
temp = (/datain/)
delete(datain)
datain = addmeta(temp,dimsizes(temp),(/"time","lat","lon"/),(/25,50,-125,-70/),""," ",yyyymmdd,-1)                
datain@_FillValue      = UNDEF 
printMinMax(datain,True)
print(stddev(datain))
if opt.eq."land" .or. opt.eq."water" then
		lsm = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat",0,dimsz, "integer")
		lsmsk = conform_dims(dimsizes(datain),lsm,(/1,2/))
		copy_VarMeta(datain,lsmsk)
		if opt.eq."land" then
				datain = mask(datain,lsmsk.eq.0,False)
		else
				datain = mask(datain,lsmsk.eq.1,False)
		end if              
end if;opt
	
if rgrd then
		orig               = datain
		Opt                = True 
		Opt@SrcFileName    = "src_SCRIP_era.nc"
		Opt@DstFileName    = "dst_SCRIP_era.nc"
		Opt@WgtFileName    = "NCEP_2_Rect_era.nc"
		Opt@ForceOverwrite = True

		;Opt@SrcGridMask    = where(.not.ismissing(orig),1,0)   ; use SrcMask2D in  
		Opt@DstGridType    = "0.25x0.25"
		Opt@DstLLCorner    = (/ 25.0d, -125.0d/)
		Opt@DstURCorner    = (/ 50.0d,   -70.0d/)
		Opt@SrcRegional    = True
		Opt@DstRegional    = True

		data_rgd = ESMF_regrid(orig,Opt)
		printVarSummary(data_rgd)
		printMinMax(data_rgd,True)
		if optplt then
				wks = gsn_open_wks("x11", "test")
				res = True
				res@gsnFrame = False
				res@gsnDraw = False
				res@gsnMaximize = True              
				res@gsnAddCyclic = False           
				res@gsnSpreadColors = True 
				res@cnFillOn = True            
				res@cnFillMode = "RasterFill"        
				res@cnLinesOn = False            
				res@cnInfoLabelOn = False
				res@cnLineLabelsOn = False
				res@cnSmoothingOn = True
				res@mpMinLatF = 25
				res@mpMaxLatF = 50
				res@mpMinLonF = -125
				res@mpMaxLonF = -70
				plot=gsn_csm_contour_map_ce(wks,data_rgd(30,:,:),res)  
				draw(plot)   
				frame(wks) 
		end if ;optplt    
		if svdata then
				fname = sat+"_"+vName+"_"+ncVarName+"_"+yrstrt+"-"+yrend+"."+Opt@DstGridType+".nc"
				system("/bin/rm -f "+fname)
				fod = addfile(fname ,"c")
				fod->DTR_025 = (/data_rgd/)
				delete(fod)
		end if ;svdata
end if; rgrd
  
	print("done")
end

;tmp   = dataAvg(hour,:,:)
;delete(dataAvg)
;tmp  = data(day,hour,:,:) 
;tmp  = addmeta(tmp,dimsz(2:3),dimNames(2:3),geoinfo,longname,units,-1,-1)
;day  = 12  
;hour = 17 
;nrec = (day-1)*nhour+hour

 