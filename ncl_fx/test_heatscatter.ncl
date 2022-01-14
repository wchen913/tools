load "./heatscatter.ncl"
;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
;---Generate 2D array of random points from 0 to 50.
  UNDEF  = -999.
  nx     =2000;365*30;365*24*6
  ny     = nx
   
  x    = random_normal(282,14,nx)
  y    = random_normal(278,12,ny)

 numbins = 20;25
 opt     = "numbers";"percent";
 colors = heatscatter(x,y,numbins,"NCV_jet")
print(dimsizes(colors)) 
 
    wks  = gsn_open_wks("x11","scatter")              ; send graphics to PNG file
   gsn_define_colormap(wks,"NCV_jet")
;---Create a scatter plot
  res                    = True
  res@gsnDraw            = False        ; Don't draw plot or advance
  res@gsnFrame           = False        ; frame. Will do this later.

  res@tiMainString       = "Density Scatter Plot"

;---Set some marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarker           = 1
 ;res@xyMarkerThicknessF = 2.5
  res@xyMarkerSizeF      = 0.05/10.
  res@xyMonoMarkerColor = False  
  res@xyMarkerColors     = colors
 
    xx=x
    yy=y
    plot = gsn_csm_xy (wks,transpose((/xx,xx/)), \
                         transpose((/yy,yy/)),res)
    draw(plot)
    frame(wks)
