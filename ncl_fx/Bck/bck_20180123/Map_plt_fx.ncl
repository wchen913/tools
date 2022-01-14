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
         res@gsnDraw    			= False
         
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
         res@lbLabelStride        = clim(4)
         
   		res@pmTickMarkDisplayMode = "Always"       

   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		
 
   		res@mpMinLatF             = min(lat1d)
   		res@mpMaxLatF             = max(lat1d)
   		res@mpMinLonF             = min(lon1d)
   		res@mpMaxLonF             = max(lon1d)
        res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
         
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

   		res@pmTickMarkDisplayMode = "Always"       

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
  		     
  		   
         wks = gsn_open_wks(pltType, pltDir+pltName)
   		gsn_define_colormap(wks,colors)   
   		plot=gsn_csm_contour_map(wks,data,res)
  		   draw(plot)
  		   frame(wks)

end
