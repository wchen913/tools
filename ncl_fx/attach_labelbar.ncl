;----------------------------------------------------------------------
; Function to attach a labelbar outside of an XY plot
;----------------------------------------------------------------------
function attach_labelbar(wks,plot,labels,colors)
local lbres, vph, vpw, nboxes,colors,labels
begin
  nboxes = dimsizes(labels)
  getvalues plot                      
    "vpHeightF" : vph                 
    "vpWidthF"  : vpw
    "vpXF":vpXF
    "vpYF":vpYF
    "tmYLLabelFontHeightF"   : fheight
    "tmYLLabelFontThicknessF": fthick
  end getvalues
  print("   vph="+vph+ "   vpw="+vpw+"  vpx="+vpXF+"    vpy="+vpYF)

  lbres                    = True          
  lbres@lbAutoManage       = False           
  lbres@lbPerimOn          = False
  lbres@vpWidthF           = 0.15 * vpw     
  lbres@vpHeightF          = vph            
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True           
  lbres@lbLabelFontHeightF = 0.02           

  lbres@lbBoxLinesOn       = False
  lbres@lbLabelAutoStride  = True
  lbres@lbLabelStride      = 20
  lbres@lbLabelJust        = "BottomLeft";"BottomRight"
  lbres@lbLabelFontHeightF = fheight*0.75
  lbres@lbLabelFontThicknessF = fthick
  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   ;getvalues lbid
   ;    "lbLabelStrings" : lbstr
   ;end getvalues
   ;print(lbstr)
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot.
;                                                                 
  amres                = True
  amres@amParallelPosF = 0.575     ; Move away from plot
  annoid = gsn_add_annotation(plot,lbid,amres)

  return(annoid)
end

