load "density.ncl" 
x    = random_normal(282,14,5000)
y    = random_normal(278,12,5000)

idat = ind(.not.(ismissing(y-x)));
if .not.all(ismissing(idat)) then
X = x(idat);
Y = y(idat);
end if 
rangx= abs(max(x)-min(x))
rangy= abs(max(y)-min(y))

colormaps = read_colormap_file("NCV_jet")
cmaps     = colormaps(51:250,:);55:25
szc       = dimsizes(cmaps)
ncolor    = szc(0)
den   = density(X,Y,"circle",30,30,0,ncolor)
;print(den+ "   "+den@indc)
indc  = den@indc
print(min(indc)+"   "+max(indc))
colors   = cmaps(indc,:)
 
   wks  = gsn_open_wks("x11","test")
     xlim  = (/240,320/) 
     ylim  = xlim  
  res                    = True
  res@gsnDraw            = False         
  res@gsnFrame           = False         
    ;res@gsnMaximize           = True
    res@vpXF                  = 0.2
    res@vpYF                  = 0.89
    res@vpHeightF             = 0.675
    res@vpWidthF              = 0.675
  res@tiMainString      = ""

    res@tiMainFontHeightF = 0.02

    res@trXMinF = xlim(0)
    res@trXMaxF = xlim(1)
    res@trYMinF = ylim(0)
    res@trYMaxF = ylim(1)

    res@tmXBMajorThicknessF     = 4
    res@tmYLMajorThicknessF     = 4
    res@tmXBLabelFontThicknessF = 4
    res@tmYLLabelFontThicknessF = 4


     res@tmBorderThicknessF= 4.0
     res@tmLabelAutoStride = True
     res@tmYROn            = False
     res@tmXTOn            = False
     res@tmYLMinorOn       = False
     res@tmXBMinorOn       = False
     res@tmXBLabelFontHeightF    = 0.03
     res@tmYLLabelFontHeightF    = 0.03

     res@tmYLLabelDeltaF   = -0.65
     res@tmXBLabelDeltaF   = -0.55

     res@tiYAxisString         = ""
    ;res@tiYAxisOffsetXF       = 0.01
     res@tiYAxisFontThicknessF = 5
     res@tiYAxisFontHeightF    = 0.03

     res@tiXAxisString         = ""
    ;res@tiXAxisOffsetYF       = 0.01
     res@tiXAxisFontThicknessF = 5
     res@tiXAxisFontHeightF    = 0.03



;---Set some marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarker           = 16
 ;res@xyMarkerThicknessF = 2.5
  res@xyMarkerSizeF      = 0.05/8.
  res@xyMonoMarkerColor = False
  res@xyMarkerColors     = colors
  plot = gsn_csm_xy (wks,transpose((/X,X/)), \
                         transpose((/Y,Y/)),res)
draw(plot)

