;******************************************************
;	This script is for US Map Plotting
;******************************************************
undef("US_Map_plt")
procedure US_Map_plt(data[*][*]:numeric,clim[4]:numeric\
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
         
   		res@gsnMaximize         = False;True;              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = True            
   	    res@cnFillMode          = "RasterFill";  "CellFill";      
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = cint
   		res@cnMinLevelValF       = cmin
   		res@cnMaxLevelValF       = cmax 

   		res@pmTickMarkDisplayMode = "Always"       
		res@pmLabelBarWidthF      		= 0.8
        res@lbLabelFontHeightF    = 0.015     
        res@lbLabelFontThicknessF = 5.
   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = clim(3)
 
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
   		
        res@tmXBMajorThicknessF         = 2.75
		res@tmYLMajorThicknessF         = 2.75
		res@tmBorderThicknessF			= 2.75
  		res@tmYLLabelDeltaF 			= -0.825
		res@tmXBLabelDeltaF 			= -0.825
		res@tmXBMajorLengthF            = 0.01
		res@tmYLMajorLengthF            = 0.01
  		;res@gsnLeftString         = lftstr   
  		;res@gsnRightString        = rgtstr   
  		     
  		   
         wks = gsn_open_wks(pltType, pltDir+pltName)
   		gsn_define_colormap(wks,colors)   
   		plot=gsn_csm_contour_map(wks,data,res)
		getvalues plot            
            "tmYLLabelFontHeightF"   : fheight
			"tmYLLabelFontThicknessF": fthick
        end getvalues
		setvalues plot            
            "tmYLLabelFontHeightF"   : fheight*1.3
			"tmYLLabelFontThicknessF": fthick*1.5
			"tmXBLabelFontHeightF"   : fheight*1.3
			"tmXBLabelFontThicknessF": fthick*1.5
        end setvalues
		 txtres               = True
         txtres@txFontHeightF = fheight*1.15
         txtres@txJust        = "BottomLeft"
		 txtres@txFontColor   = "red"
		 xp = -122.5
		 yp = 27.5
		 dum1 = gsn_add_text(wks,plot,lftstr,xp,yp,txtres)
		 
		 txtres@txJust        = "BottomRight"
         txtres@txFontColor   = "black"
         xp = -72.5
		 yp = 47.75
		 dum1 = gsn_add_text(wks,plot,rgtstr,xp,yp,txtres)

  		 draw(plot)
  		 frame(wks)

end
;********************************
undef("US_Map_plt_pd")
function US_Map_plt_pd(wks:graphic,data[*][*]:numeric,clim[4]:numeric,tistrs[3]:string,opt:logical)
local res,cmin,cmax,cint,tistr,lftstr,rtstr,plot
begin
cmin     = clim(0)
cmax     = clim(1)
cint     = clim(2)

tistr    = tistrs(0)
lftstr   = tistrs(1)
rgtstr   = tistrs(2)

	delete(data@long_name)
	delete(data@units)
   		
       
   		res                     = True
   		res@gsnFrame            = False
        res@gsnDraw    			= False
         
   		res@gsnMaximize         = False              
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
  
   		res@cnFillOn            = True            
   	    res@cnFillMode          = "RasterFill"; "CellFill";      
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = cint
   		res@cnMinLevelValF       = cmin
   		res@cnMaxLevelValF       = cmax 

   		res@pmTickMarkDisplayMode = "Always"  
		
        res@lbLabelBarOn          = opt 
       ;res@lbOrientation         = "Vertical"
   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		res@lbLabelStride         = clim(3)
 
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
		plot=gsn_csm_contour_map(wks,data,res)
		return(plot)
end
undef("US_Map_plt_update")
function US_Map_plt_update(wks:graphic,data[*][*]:numeric,clim[4]:numeric,optId:logical,optStr:logical,opt:logical)
local res,plot,fheight,fthick
begin
 
	delete(data@long_name)
	delete(data@units)
   		
       
   		res                     = True
   		res@gsnFrame            = False
        res@gsnDraw    			= False
         
   		res@gsnMaximize         = False  
       ;res@vpHeightF             = 0.975
       ;res@vpWidthF              = 0.8
        
   		res@gsnAddCyclic        = False           
   		res@gsnSpreadColors     = True            
       
   		res@cnFillOn            = True            
   	    res@cnFillMode          = "RasterFill";   "CellFill";    
   		res@cnLinesOn           = False            
   		res@cnInfoLabelOn       = False
   		res@cnLineLabelsOn      = False

   		res@cnLevelSelectionMode = "ManualLevels"
   		res@cnLevelSpacingF      = clim(2)
   		res@cnMinLevelValF       = clim(0)
   		res@cnMaxLevelValF       = clim(1)

   		res@pmTickMarkDisplayMode = "Always" 
		res@lbLabelFontHeightF    = 0.015     
        res@lbLabelFontThicknessF = 4.       
        res@lbLabelBarOn          = opt
    if opt.and.isatt(opt,"Orientation") then 
       res@lbOrientation         = opt@Orientation
    end if    
   		res@lbBoxLinesOn          = False            
   		res@lbBoxSeparatorLinesOn = False
   		;res@lbLabelStride         = clim(3)
        res@lbLabelAutoStride      = True
        
   		res@mpMinLatF             = 25
   		res@mpMaxLatF             = 50
   		res@mpMinLonF             = -125
   		res@mpMaxLonF             = -70
        res@mpCenterLonF          = 0.5*(res@mpMinLonF+res@mpMaxLonF )
        
        res@tmXBMajorThicknessF     = 2.5
        res@tmYLMajorThicknessF     = 2.5
        res@tmXBLabelFontThicknessF = 2.5
        res@tmYLLabelFontThicknessF = 2.5
        res@tmBorderThicknessF      = 2.5
        
        res@tmYLLabelDeltaF 			= -0.825
		res@tmXBLabelDeltaF 			= -0.825
        res@mpOutlineBoundarySets = "USStates";"AllBoundaries" ; "National" 
   		res@mpDataSetName         = "Earth..4"
        res@mpDataBaseVersion     = "MediumRes"
        res@cnFillDrawOrder       = "PreDraw"

        res@mpOceanFillColor      = "white"
        res@mpInlandWaterFillColor= "white"
        res@mpLandFillColor       = "transparent"
   		
      if optStr.and.isatt(optStr,"tistr") then 
  		res@tiMainString          = optStr@tistr
      end if  
      if optStr.and.isatt(optStr,"lftstr") then 
  		res@gsnLeftString          = optStr@lftstr
      end if 
      if optStr.and.isatt(optStr,"rgtstr") then 
  		res@gsnRightString         = optStr@rgtstr
      end if  
		plot=gsn_csm_contour_map(wks,data,res)
        getvalues plot            
            "tmYLLabelFontHeightF"   : fheight
			"tmYLLabelFontThicknessF": fthick
        end getvalues
		setvalues plot            
            "tmYLLabelFontHeightF"   : fheight*1.3
			"tmYLLabelFontThicknessF": fthick*1.5
			"tmXBLabelFontHeightF"   : fheight*1.3
			"tmXBLabelFontThicknessF": fthick*1.5     
        end setvalues
       
        if optId then 
            print("add figure ID")
            if (dimsizes(optId@IdStr).eq.dimsizes(optId@Xp)).and.(dimsizes(optId@IdStr).eq.dimsizes(optId@Yp)) then
            print(optId@IdStr)
             txres               = True
             txres@txJust        = "BottomLeft"
             txres@txFontHeightF = fheight*1.2
             txres@txFontThicknessF = fthick*2	
             plot@$unique_string("dum")$ = gsn_add_text(wks,plot,optId@IdStr,optId@Xp,optId@Yp, txres) 
            else
                print("size of string properties does not equal")
                exit
            end if
        end if         
   
       
		return(plot)
end
