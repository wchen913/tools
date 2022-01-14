;******************************************************
;	This script is for  Map Plotting
;******************************************************
undef("Map_plt_Sat_2d")
procedure Map_plt_Sat_2d(data1d[*]:numeric,lat1d[*]:numeric,lat1d[*]:numeric,clim[3]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors[1]:string\
                    ,tistr[1]:string,lftstr[1]:string,rgtstr[1]:string\
                    ,opt)
local res,cmin,cmax,cint,plot

begin
    
   cmin     = clim(0)
   cmax     = clim(1)
   cint     = clim(2)
 
	
	delete(data@long_name)
	delete(data@units)
   		
       
   		res                     = True
   		res@gsnFrame            = False
         res@gsnDraw    		= False         
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = True            
   	    res@cnFillMode          = "RasterFill";"CellFill";        
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False
        

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = cint
   		res@cnMinLevelValF       = cmin
   		res@cnMaxLevelValF       = cmax 
        res@lbLabelStride       = clim(4)
         
   		;res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		
 
   		res@tmXBMajorThicknessF     = 3
        res@tmYLMajorThicknessF     = 3
        res@tmBorderThicknessF      = 3
        res@mpGeophysicalLineThicknessF = 2

        res@tmXBLabelFontThicknessF = 5
        res@tmYLLabelFontThicknessF = 5 
        res@tmYLLabelFontHeightF	= 0.0175
        res@tmXBLabelFontHeightF	= 0.0175
        
        res@tmYLLabelDeltaF 			= -0.725
		res@tmXBLabelDeltaF 			= -0.825

        ;res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
         
        res@mpOutlineBoundarySets = "AllBoundaries" ;"USStates"; "National" 
   		res@mpDataSetName         = "Earth..4"
        res@mpDataBaseVersion     = "MediumRes"
        res@cnFillDrawOrder       = "PreDraw"

       if opt.eq."water" then
        res@mpOceanFillColor      = "white"
        res@mpInlandWaterFillColor= "white"
        res@mpLandFillColor       = "transparent"
   	 end if	
       if opt.eq."land" then
        res@mpOceanFillColor      = "transparent"
        res@mpInlandWaterFillColor= "transparent"
        res@mpLandFillColor       = "white"
   	 end if	
  		res@tiMainString          = tistr
  		res@gsnLeftString         = lftstr   
  		res@gsnRightString        = rgtstr   
  		     
  		   
         wks = gsn_open_wks(pltType, pltDir+pltName)
   		gsn_define_colormap(wks,colors)   
   		plot=gsn_csm_contour_map(wks,data,res)
  		   draw(plot)
  		   frame(wks)

end
;======================================================
undef("US_Map_plt")
procedure US_Map_plt(data[*][*]:numeric,clim[3]:numeric\
                    ,pltType[1]:string, pltDir[1]:string\
                    ,pltName[1]:string, colors[1]:string\
                    ,tistr[1]:string,lftstr[1]:string,rgtstr[1]:string\
                    ,opt)
local res,cmin,cmax,cint,plot

begin
    
   cmin     = clim(0)
   cmax     = clim(1)
   cint     = clim(2)
 
	
	delete(data@long_name)
	delete(data@units)
   		
       
   		res                     = True
   		;res@gsnFrame            = False
        ;res@gsnDraw    			= False
         
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = True            
   	    res@cnFillMode          = "CellFill";"RasterFill"        
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = cint
   		res@cnMinLevelValF       = cmin
   		res@cnMaxLevelValF       = cmax 

   		;res@pmTickMarkDisplayMode = "Always"       
		XBValues = (/-120,-110,-100,-90,-80,-70/)
   		XBLabels = (/"120~F34~0~F~W", "110~F34~0~F~W","100~F34~0~F~W",\
        "90~F34~0~W~","80~F34~0~F~W","70~F34~0~F~E"/)
   		res@tmXBMode   = "Explicit"
  		res@tmXBValues = XBValues
  		res@tmXBLabels = XBLabels

        YLValues = (/25,30,35,40,45,50/)
        YLLabels = (/"25~F34~0~F~N","30~F34~0~F~N","35~F34~0~F~N",\
                     "40~F34~0~F~N","45~F34~0~F~N","50~F34~0~F~N"/)
  		res@tmYLMode   = "Explicit"
  		res@tmYLValues = YLValues
 	    res@tmYLLabels = YLLabels
 	    
   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = 5*2
 
   		res@mpMinLatF             = 25
   		res@mpMaxLatF             = 50
   		res@mpMinLonF             = -125
   		res@mpMaxLonF             = -70
        res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
         
        res@mpOutlineBoundarySets = "USStates";"AllBoundaries" ; "National" 
   		res@mpDataSetName         = "Earth..4"
        res@mpDataBaseVersion     = "MediumRes"
        res@cnFillDrawOrder       = "PreDraw"

        res@mpOceanFillColor      = "white"
        res@mpInlandWaterFillColor= "white"
        res@mpLandFillColor       = "transparent"
   		
       
  		res@tiMainString          = tistr
  		res@gsnLeftString         = lftstr   
  		res@gsnRightString        = rgtstr   
  		     
  		 res@tmXBMajorThicknessF     = 3
        res@tmYLMajorThicknessF     = 3
        res@tmBorderThicknessF      = 3
        res@mpGeophysicalLineThicknessF = 2

        res@tmXBLabelFontThicknessF = 5
        res@tmYLLabelFontThicknessF = 5 
        res@tmYLLabelFontHeightF	= 0.0175
        res@tmXBLabelFontHeightF	= 0.0175
        
        res@tmYLLabelDeltaF 			= -0.725
		res@tmXBLabelDeltaF 			= -0.825
  
         wks = gsn_open_wks(pltType, pltDir+pltName)
   		gsn_define_colormap(wks,colors)   
   		plot=gsn_csm_contour_map(wks,data,res)
  		   draw(plot)
  		   frame(wks)

end

;******************************************************
;	This script is for  Map Plotting
;General Plot
;single map plot only
;data: must have two named (lat/lon) dimensions
;opt:land~maskout land;water~maskout water
;******************************************************
undef("Map_Plot_Region")
function Map_Plot_Region(wks:graphic,data[*][*]:numeric,clim[4]:numeric,opt,mapres:string)                                        
                    
local res,cmin,cmax,cint,plot,lbint

begin
    
   cmin     = clim(0)
   cmax     = clim(1)
   cint     = clim(2)
   lbint    = clim(3)
    
   		res                     = True
   		res@gsnFrame            = False
         res@gsnDraw    			= False
         
   		res@gsnMaximize         = True              
   		res@gsnAddCyclic        = False           
   		;res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = True               
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False
   		;res@cnSmoothingOn = True 

   	  ;res@cnFillMode          = "RasterFill"

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = cint
   		res@cnMinLevelValF       = cmin
   		res@cnMaxLevelValF       = cmax 

        
   		;res@tmXBMajorThicknessF     = 3
        res@tmYLMajorThicknessF     = 3
        res@tmBorderThicknessF      = 3
        res@mpGeophysicalLineThicknessF = 2

        res@tmXBLabelFontThicknessF = 5
        res@tmYLLabelFontThicknessF = 5 
        res@tmYLLabelFontHeightF	= 0.0175
        res@tmXBLabelFontHeightF	= 0.0175
        
        res@tmYLLabelDeltaF 			= -0.725
		res@tmXBLabelDeltaF 			= -0.825
		;res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = lbint
 
   		 res@mpMinLatF             = min(data&lat)
   		 res@mpMaxLatF             = max(data&lat)
   		 res@mpMinLonF             = min(data&lon)
   		 res@mpMaxLonF             = max(data&lon)
         res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
         res@gsnLeftString         = ""
         res@gsnRightString        = ""
         res@gsnCenterString       = ""
         ;                           res@mpGridAndLimbOn       = True

       ;res@mpOutlineBoundarySets = "USStates";"National";"USStates";"AllBoundaries" ; "National" 
        res@mpDataBaseVersion     = mapres

        if opt.eq."water" then
		res@cnFillDrawOrder       = "PreDraw"        
         res@mpOceanFillColor      = "white"
         res@mpInlandWaterFillColor= "white"
         res@mpLandFillColor       = "transparent"
   	  end if	
       if opt.eq."land" then
		res@cnFillDrawOrder       = "PreDraw"        
         res@mpOceanFillColor      = "transparent"
         res@mpInlandWaterFillColor= "transparent"
         res@mpLandFillColor       = "white"         
   	  end if	     
  		   
         
   		plot=gsn_csm_contour_map(wks,data,res)
  		   return(plot)

end
;******************************************************
;	This script is for  Map Plotting
;General Plot
;single map plot only
;data: must have two named (lat/lon) dimensions
;opt:land~maskout land;water~maskout water
;******************************************************
undef("Map_SF_Plot_Region_R")
function Map_SF_Plot_Region_R(wks:graphic,data[*]:numeric,\
                              lat1d[*]:numeric,lon1d[*]:numeric,\
                              clim[4]:numeric,opt)                                        
                    
local res,cmin,cmax,cint,plot,lbint

begin
   cmin     = clim(0)
   cmax     = clim(1)
   cint     = clim(2)
   lbint    = clim(3)
   
                res                     = True
                res@gsnFrame            = False
                res@gsnDraw             = False


                res@gsnMaximize         = True
                res@gsnAddCyclic        = False
                res@gsnSpreadColors     = True

                res@cnFillOn            = True
                res@cnFillMode          = "RasterFill"
                res@cnLinesOn           = False
                res@cnInfoLabelOn       = False
                res@cnLineLabelsOn      = False

                 res@cnLevelSelectionMode = "ManualLevels"
                 res@cnLevelSpacingF      = cint
                 res@cnMinLevelValF       = cmin
                 res@cnMaxLevelValF       = cmax

                res@pmTickMarkDisplayMode = "Always"

                res@lbBoxLinesOn          = False
                res@lbBoxSeparatorLinesOn = False
                res@lbLabelStride         = lbint

                res@sfYArray              = lat1d 
                res@sfXArray              = lon1d 

                res@mpMinLatF             = min(lat1d) 
                res@mpMaxLatF             = max(lat1d) 
                res@mpMinLonF             = min(lon1d) 
                res@mpMaxLonF             = max(lon1d) 
res@tmXBMajorThicknessF     = 3
        res@tmYLMajorThicknessF     = 3
        res@tmBorderThicknessF      = 3
        res@mpGeophysicalLineThicknessF = 2

        res@tmXBLabelFontThicknessF = 5
        res@tmYLLabelFontThicknessF = 5 
        res@tmYLLabelFontHeightF	= 0.0175
        res@tmXBLabelFontHeightF	= 0.0175
        
        res@tmYLLabelDeltaF 			= -0.725
		res@tmXBLabelDeltaF 			= -0.825

               res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
               res@gsnLeftString         = ""
               res@gsnRightString        = ""
               res@gsnCenterString       = ""
   	         res@mpDataSetName         = "Earth..4"
        
               ;res@mpOutlineBoundarySets = "USStates";"National";"USStates";"AllBoundaries" ; "National" 
        
               if opt.eq."water" then
                  res@mpDataBaseVersion     = "HighRes"
                  res@cnFillDrawOrder       = "PreDraw"
                  res@mpOceanFillColor      = "white"
                  res@mpInlandWaterFillColor= "white"
                  res@mpLandFillColor       = "transparent"
   	         end if	
               if opt.eq."land" then
                  res@mpDataBaseVersion     = "HighRes"
                  res@cnFillDrawOrder       = "PreDraw"
                  res@mpOceanFillColor      = "transparent"
                  res@mpInlandWaterFillColor= "transparent"
                  res@mpLandFillColor       = "white"         
   	         end if	     
               plot=gsn_csm_contour_map(wks,data,res)
               return(plot)

end
