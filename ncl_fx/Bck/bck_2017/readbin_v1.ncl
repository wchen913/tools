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
;*******************************
; For binary files 
;******************************* 


  
  nlat  = 501
  nlon  = 1101
  yymm="0003"
  dd="12"
  hh="17"  
  alg=(/"skm.i.11um_wv","skm.i.generalSplitWindow","skm.i.proposedSplitWindow"/)
  iAlg=1
  

% **** input GOES-WEST (GOES-10) ****
   filePath = "/aosc/helios2/ytma/data_helios2/LST/goes10/lst/"+yymm+"/
   fileName = filePath+yymm+"_"+mntStr+"_"+alg(iAlg);
   nrec     =((dyoi-1)*24 + hroi ) * nLon*nLat*4;
   lst = fbindirread(filename, 0,-1, "float")
   print(dimsizes(lst))
   lst@_FillValue =-999.

  printMinMax(lst,True)
   fid = fopen(fileName,'r');
      pos = ( (dyoi-1)*24 + hroi ) * nLon*nLat*4; %in bytes
      fseek(fid,pos,'bof');
      lst = fread(fid,nLon*nLat,'float32');
   fclose(fid);
   lst(lst<-900)=NaN;
   lst = reshape(lst,[nLon,nLat]);
   lst10 = lst;
   fname10 = fileName;
   
% **** input GOES-EAST (GOES-8) ****
   filePath = ['/aosc/helios2/ytma/data_helios2/LST/goes8/lst/',yymm,'/'];
   fileName = [filePath,'/',yymm,alg];
   
   fid = fopen(fileName,'r');
      pos = ( (dyoi-1)*24 + hroi ) * nLon*nLat*4; %in bytes
      fseek(fid,pos,'bof');
      lst = fread(fid,nLon*nLat,'float32');
   fclose(fid);
   lst(lst<-900)=NaN;
   lst = reshape(lst,[nLon,nLat]);
   lst8 = lst;
   fname8 = fileName;
%}
MODpth = "data/crash/nshahi/MODIS/"
  filename="lst10_"+alg(i)+"_"+yymm+dd+hh+".dat"
  wksname = "nclLSTtest"
  wkstype = "ps"
  wkstype@wkOrientation = "landscape"
  
  nlat  = 501
  nlon  = 1101
  nrec  = 0
  dims  = (/501,1101/)
;--- read in Geo infomation
   lon  = fbindirread("lon1d.dat", 0,-1, "float")
   replace_ieeenan(lon,-999.0,0)
   lon@_FillValue =-999.
   print(dimsizes(lon))

   lat = fbindirread("lat1d.dat", 0,-1, "float")
   replace_ieeenan(lat,-999.0,0)
   lat@_FillValue =-999.
   print(dimsizes(lat))
   lat=lat(::-1)

   lon2d = fbindirread("lon2d.dat", 0,-1, "float")
   replace_ieeenan(lon2d,-999.0,0)
   lon2d@_FillValue =-999.
   lon2D=onedtond(lon2d,dims)
   print(dimsizes(lon2d))

   lat2d = fbindirread("lat2d.dat", 0,-1, "float")
   lat2d = lat2d(::-1)
   replace_ieeenan(lat2d,-999.0,0)
   lat2d@_FillValue =-999.
   lat2D=onedtond(lat2d,dims)
   print(dimsizes(lat2D))
    

;read in LST
  lst = fbindirread(filename, 0,-1, "float")
  print(dimsizes(lst))
  replace_ieeenan(lst,-999.0,0)
  lst@_FillValue =-999.
  printMinMax(lst,True)
  lst2d= onedtond(lst,dims)
  lst2d=lst2d(::-1,:)

;---Name dimensions of t and assign coordinate variables
;---Create lat and long coordinate variables
   lon!0          = "lon"
   lon@long_name  = "lon"
   lon@units      = "degrees-east"
   lon&lon        = lon

   lat!0          = "lat"
   lat@long_name  = "lat"
   lat@units      = "degrees_north"
   lat&lat        = lat

;---Name dimensions of t and assign coordinate variables
   lst2d!0    = "lat"
   lst2d!1    = "lon"
   lst2d&lat  = lat
   lst2d&lon  = lon
   
  lst2d@lat2d  = lat2D
  lst2d@lon2d  = lon2D
  lst2d@long_name = "Land Skin temperature"
  lst2d@short_name = "LST"
  lst2d@units     = "degK"
 
   

   wks = gsn_open_wks(wkstype, wksname)

   gsn_define_colormap(wks,"NCV_jet")             ; choose a color map
  ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); choose a color map

   res                     = True
   res@gsnMaximize         = True            ; ps, pdf, pdf    
   res@gsnAddCyclic        = False           ; data not cyclic
   res@gsnSpreadColors     = True            ; use full colormap
  
   res@cnFillOn            = True            ; turn on color
   ;res@cnFillMode          = "RasterFill"    ; raster mode
   res@cnFillMode          = "CellFill"     ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
   res@lbOrientation       = "Vertical"      ; vertical label bar
   res@lbLabelAutoStride   = True            ; let NCL decide spacing
   res@lbBoxSeparatorLinesOn = False

  ;res@cnLevelSelectionMode = "ManualLevels"
  ;res@cnLevelSpacingF      = (400-100)/64
  ;res@cnMinLevelValF       = 100.
  ;res@cnMaxLevelValF       = 400.
 
   res@mpMinLatF           = min(lat2D)     ; region to zoom in on
   res@mpMaxLatF           = max(lat2D)
   res@mpMinLonF           = min(lon2D)
   res@mpMaxLonF           = max(lon2D)

   res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   res@mpFillOn            = False

   res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
  ;res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   res@gsnLeftString       = lst2d@short_name
   res@tiMainString        = ""
     
   plot=gsn_csm_contour_map_ce(wks,lst2d,res)
   ;draw(plot)
   ;frame(wks)
end

