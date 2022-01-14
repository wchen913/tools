;*************************************************
; scatter_8.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors
;   - Generating dummy data using "random_uniform"
;   - Drawing a labelbar outside an XY plot
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;   - Manually creating a labelbar
;
;*************************************************
;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
;---Generate 2D array of random points from 0 to 50.
  UNDEF  = -999.
  nx     = 365*24*6
  ny     = nx
   
  x    = random_normal(282,14,nx)
  y    = random_normal(278,12,ny)

  numbins = 25
  
  pdf2       = pdfxy(x,y,numbins,numbins,False)

  onepercent = round(dimsizes(x) / 100,0)
 ;values     = tofloat(pdf2*onepercent)
  values     = tofloat(pdf2*100)
  printMinMax(values, True)  
 ;print(pdf2)
 ;print("*"+onepercent)
 ;printVarSummary(values)
 ;print(values)
 
  centers_X = tofloat(pdf2@binx_center)
  centers_Y = tofloat(pdf2@biny_center)
    

    binsize_X = abs(centers_X(1) - centers_X(0)) / 2
    binsize_Y = abs(centers_Y(1) - centers_Y(0)) / 2

    bins_X = new((/numbins, 2/),typeof(x))
    bins_Y = new((/numbins, 2/),typeof(y))
    bins_X = 0
    bins_Y = 0
    print(typeof(centers_X)+"  "+typeof(bins_X)+" "+typeof(binsize_X))
 
    do i = 0,numbins-1
        bins_X(i, 0) = centers_X(i) - binsize_X
        bins_X(i, 1) = centers_X(i) + binsize_X
        bins_Y(i, 0) = centers_Y(i) - binsize_Y
        bins_Y(i, 1) = centers_Y(i) + binsize_Y
    end do;i
   ;print(bins_X+" *** "+bins_Y)


    print("Generating colormap...");
    scatter_COL = new(dimsizes(x), typeof(x));
    scatter_COL = 0
    do i = 0,dimsizes(x)-1

        if (mod(i,onepercent) .eq. 0)
            print("..........")
        end if
        
        last_higher_X := UNDEF
        last_lower_X  := UNDEF
        id_X          := UNDEF
        c_X = x(i)
        ;print(" **** "+c_X)
        last_lower_X := ind(c_X .ge. bins_X(:,0))
        if (.not.all(ismissing(last_lower_X)))
            nlast_lower_X=dimsizes(last_lower_X )
            last_lower_X:= last_lower_X(nlast_lower_X-1)
        else
            last_higher_X := ind(c_X .le. bins_X(:,1))
            if (.not.all(ismissing(last_higher_X)))
                last_higher_X := last_higher_X(0)
            end if 
        end if
        
        if (last_lower_X.ne.UNDEF)
            id_X = last_lower_X
        else
            if (last_higher_X.ne.UNDEF)
                id_X = last_higher_X
            end if
        end if
        ;print(" *** **"+id_X) 
       
        last_higher_Y := UNDEF
        last_lower_Y  := UNDEF
        id_Y          := UNDEF
        c_Y = y(i)
        last_lower_Y := ind(c_Y .ge. bins_Y(:,0))
        if (.not.all(ismissing(last_lower_Y)))
            nlast_lower_Y=dimsizes(last_lower_Y)
            last_lower_Y := last_lower_Y(nlast_lower_Y-1)
        else
            last_higher_Y := ind(c_Y .le. bins_Y(:,1))
            if (.not.all(ismissing(last_higher_Y)))
                last_higher_Y := last_higher_Y(0)
            end if;isempty
        end if;isempty
        if (last_lower_Y.ne.UNDEF)
            id_Y = last_lower_Y
        else
            if (last_higher_Y.ne.UNDEF)
                id_Y = last_higher_Y
            end if
        end if 

        scatter_COL(i) = values(toint(id_X), toint(id_Y));
       ;print(" *** ***"+id_Y)
       ;print(values(toint(id_X), toint(id_Y)))
    end do;i
   ;print(scatter_COL(:))
   ;scatter_COL=where(scatter_COL.lt.2,2,scatter_COL)
    printMinMax(scatter_COL,True)
    print("Plotting...")


    cmap = read_colormap_file("NCV_jet")
    colors =cmap(2:,:)
    print(dimsizes(colors)) 
     
;exit
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
  res@xyMarkerColors     = colors(toint(scatter_COL),:)
 
    xx=x
    yy=y
    plot = gsn_csm_xy (wks,transpose((/xx,xx/)), \
                         transpose((/yy,yy/)),res)
    draw(plot)
    frame(wks)
