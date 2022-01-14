;******************************************************
;	This script is for US Map Plotting
;******************************************************
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
  		  ;draw(plot)
  		  ;frame(wks)

end
