;*************************************************
; polyg_12.ncl
;
; Concepts illustrated:
;   - Using draw order resources to mask areas in a plot
;   - Attaching filled polygons to a map
;   - Attaching polylines to a map plot
;   - Attaching text strings to a map
;   - Turning off map tickmarks

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  latS  = -60.
  latN  =  60.
  lonC  = 240.

  latST = -20.
  latNT =  20.


  wks  = gsn_open_wks("ps","polyg")     ; open a ps file
  
  res = True
  res@gsnDraw      = False
  res@gsnFrame     = False

  res@mpMaxLatF    = latN
  res@mpMinLatF    = latS
  res@mpCenterLonF = lonC

  res@mpFillOn = True
  res@mpFillColors = (/-1,0,-1,-1/)
  res@mpOutlineOn = True

  plot = gsn_csm_map_ce(wks,res)        ; draw global map
  resp = True
  resp@gsFillColor = "blue"

; After V5.1.1, you can set this resource as part of the "resp" resource list.
  setvalues plot 
    "tfPolyDrawOrder" : "Draw"
  end setvalues
; resp@tfPolyDrawOrder = "Draw"                      ; default is "PostDraw"  

  xpts = (/360.0, 0.0,0.0, 360.0,360.0/)
  ypts = (/ 20.0,  20.0,  40.0,  40.0, 20.0/) 
  dum = gsn_add_polygon(wks,plot,xpts,ypts,resp)

  ypts = (/ -20.0,  -20.0,  -40.0,  -40.0, -20.0/)
  resp@gsFillColor = "red"
  dum2 = gsn_add_polygon(wks,plot,xpts,ypts,resp)
  draw(plot)

;---------------------------------------------------------
;   Draw tropical plot, along with green/yellow polygons
;---------------------------------------------------------    
  res@mpMaxLatF = 20.
  res@mpMinLatF = -20
  res@tmXBOn = False
  res@tmXTOn = False
  res@tmXTBorderOn = False
  res@tmXBBorderOn = False
  res@tmXBLabelsOn = False
  res@tmYLBorderOn = False
  res@tmYRBorderOn = False
  res@tmYLLabelsOn = False
  res@tmYLOn = False
  res@tmYROn = False
  res@mpFillColors = (/-1,-1,0,-1/)
  plot2 = gsn_csm_map_ce(wks,res)        ; draw global map

; After V5.1.1, you can set this resource as part of the "resp" resource list.
  setvalues plot2 
    "tfPolyDrawOrder" : "Draw"
  end setvalues
;  resp@tfPolyDrawOrder = "Draw"                      ; default is "PostDraw"  

  resp@gsFillColor = "green"
  ypts = (/ 20.0,  20.0,  0.0,   0.0, 20.0/)
  dum3 = gsn_add_polygon(wks,plot2,xpts,ypts,resp)

  ypts = (/ -20.0,  -20.0,  0.0,   0.0, -20.0/)
  resp@gsFillColor = "yellow"
  dum4 = gsn_add_polygon(wks,plot2,xpts,ypts,resp)
  draw(plot2)

;-------------------------------------------------
;   Draw map border, to cover up poylgon fills
;-------------------------------------------------
  res@mpFillColors = (/-1,-1,-1,-1/)
  res@tmXTBorderOn = True
  res@tmXBBorderOn = True
  res@tmYLBorderOn = True
  res@tmYRBorderOn = True
  res@mpMaxLatF = latN
  res@mpMinLatF = latS
  res@mpOutlineOn = False
  plot3 = gsn_csm_map_ce(wks,res)        ; draw global map

;-------------------------------------------------
;   Draw text
;-------------------------------------------------    
  lonTxt = 205.
  sres = True
  sres@txFontHeightF = 0.015
  sres@txFontColor = "blue"
  dum5 = gsn_add_text(wks,plot3,"NLD",lonTxt,50,sres)
  sres@txFontColor = "white"
  dum6 = gsn_add_text(wks,plot3,"NTO",lonTxt,10,sres)
  dum7 = gsn_add_text(wks,plot3,"STO",lonTxt,-10,sres)
  sres@txFontColor = "red"
  dum8 = gsn_add_text(wks,plot3,"SLD",lonTxt,-50,sres)

;-------------------------------------------------
;   Draw lines
;-------------------------------------------------      
  pres = True
  pres@gsLineColor = "blue"
  pres@gsLineThicknessF = 1.5
  dum9 = gsn_add_polyline(wks,plot3,(/192,125/),(/48,30/),pres)
  dum10 = gsn_add_polyline(wks,plot3,(/205,240/),(/45,30/),pres)
  dum11 = gsn_add_polyline(wks,plot3,(/218,350/),(/48,35/),pres)
  
  pres@gsLineColor = "red"
  dum12 = gsn_add_polyline(wks,plot3,(/192,155/),(/-48,-30/),pres)
  dum13 = gsn_add_polyline(wks,plot3,(/205,285/),(/-43,-30/),pres)
  dum14 = gsn_add_polyline(wks,plot3,(/218,375/),(/-50,-35/),pres)
 
  draw(plot3)
  frame(wks)
end


