load "/data/srb1/wchen/tools/ncl_fx/substring.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/Map_plt_fx.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"

begin
;*******************************
; For binary files 
;******************************* 
;------ head
;+++ Parameters 
	svdata	 = True
	pltMap	 = True
    Region   = "LakeHuron"
 	nLat	 = 501
	nLon	 = 1101

	geoinfo  = (/25,50,-125.,-70/)
	dimsz	 = (/nLat,nLon/)
	dimNames = (/"lat","lon"/)
	datatype = "float"
	units	 = "(K)"
	nrec	 = 0
    UNDEF  = -999.
	
 
;---- Processing
   print("data processing")
;+++ loop
    lsm      = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat",0,dimsz, "integer")
    lsm      = addmeta(lsm,dimsz,(/"lat","lon"/),(/25,50,-125,-70/),"land sea mask"," ",-1,-1)
    ;box      = new((/81,121/),typeof(lsm),UNDEF) ; Lake Huron{43:47},{-85:-79} 

     
 
	box    	 = lsm({43:47},{-85:-79})
        
       printVarSummary(box)
       printMinMax(box,True)
      
       
            
            nlat    = dimsizes(box&lat)
            nlon    = dimsizes(box&lon)
            lat     = box&lat
            lon     = box&lon
            

           
           ; box!0    = "lat"
           ; box&lat  = lat
           ; box!1    = "lon"
           ; box&lon  = lon

    if svdata  then
            print("Write NetCDF Data")
            vName   = "lsm"
            fname = "./"+"lsmsk."+Region+".S-N.W-E"+".nc"
      
            print(fname)
           ;exit
            system("/bin/rm -f "+fname)
            fnc                 = addfile(fname,"c")
            
            fnc->lat        = (/lat/)
            fnc->lon        = (/lon/)
            fnc->$vName$    = box

             
            delete(fnc)
    end if ;svdata
      
 
;******************************************************
;						 Plotting
;******************************************************
	
;+++ MAP
if pltMap then 
	
	     
	      lftstr    = "Lake Huron"
	      rtstr     = " " 
	      tistr     = "" 
	      
	      tmp     = box 
	     
	      delete(tmp@long_name)
	      delete(tmp@units)
	      print("Map Plotting")
          

   		wks = gsn_open_wks("x11", "test")
   		gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose a color map; MPL_jet
  		   ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); 

   		res                     = True
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
  
   		res@cnFillOn            = True            
   		;res@cnFillMode          = "RasterFill"        
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		 
         
   		res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
  
   		res@mpMinLatF             = min(tmp&lat);geoinfo(0)
   		res@mpMaxLatF             = max(tmp&lat);geoinfo(1)
   		res@mpMinLonF             = min(tmp&lon);geoinfo(2)
   		res@mpMaxLonF             = max(tmp&lon);geoinfo(3)
        
         res@mpDataSetName               = "Earth..4"
         res@mpDataBaseVersion           = "MediumRes";"HighRes";

         res@mpOutlineOn                 = True
         

   		res@mpOutlineBoundarySets = "USStates" ;"AllBoundaries" ;   ; "National" 
   		 
         res@gsnLeftString  = lftstr
         res@gsnRightString = rtstr
        
   		plot=gsn_csm_contour_map(wks,tmp,res)
  		 draw(plot)
  		 frame(wks)
	end if



	print("done")


end
;if (isbigendian() ) then
;	setfileoption("bin","ReadByteOrder","BigEndian")
;end if

;tmp   = dataAvg(hour,:,:)
;delete(dataAvg)
;tmp  = data(day,hour,:,:) 
;tmp  = addmeta(tmp,dimsz(2:3),dimNames(2:3),geoinfo,longname,units,-1,-1)
;day		 = 12  
;hour	 = 17 
;nrec	 = (day-1)*nhour+hour

   ;res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   ;res@mpFillOn            = False
   ;res@lbOrientation       = "Vertical"
   ;res@lbLabelAutoStride   = True    
   ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
  ;res@cnFillMode          = "CellFill"  
 ;res1@gsnHistogramSelectNiceIntervals = False
  ;res1@gsnHistogramNumberOfBins        = 61 
  ;res1@gsnHistogramComputePercentages	= True
   ;res1@gsnHistogramPercentSign		= True
