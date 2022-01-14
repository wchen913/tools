;*************************************************
; heatscatter.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors
;
;*************************************************
;This function is to generate density scatter plot color map
undef("heatscatter")
function heatscatter(x[*]:numeric,y[*]:numeric,numbins:numeric,mapname:string)
local UNDEF,pdf2,onepercent,values,\
      centers_X,centers_Y,binsize_X,binsize_Y,\
      bins_X,bins_Y,i,scatter_COL,\
      last_lower_X,last_lower_Y,last_higher_X,last_higher_Y,\
      id_X,id_Y,c_X,c_Y,cmap,subcmap,szcmap,ncolor,colors
begin
 
  UNDEF  = -999. 
  pdf2       = pdfxy(x,y,numbins,numbins,False)

  onepercent = round(dimsizes(x) / 100,0)
  print("onepercent= "+onepercent)
  
  ;values     = tofloat(pdf2*onepercent)
   values     = tofloat(pdf2*100)
  print("****** Min Max of Values *******")
  printMinMax(values, True)  
  print("********************************")
    
  centers_X = tofloat(pdf2@binx_center)
  centers_Y = tofloat(pdf2@biny_center)    

  binsize_X = abs(centers_X(1) - centers_X(0)) / 2
  binsize_Y = abs(centers_Y(1) - centers_Y(0)) / 2

  bins_X = new((/numbins, 2/),typeof(x))
  bins_Y = new((/numbins, 2/),typeof(y))
  bins_X = 0
  bins_Y = 0
  
  do i = 0,numbins-1
        bins_X(i, 0) = centers_X(i) - binsize_X
        bins_X(i, 1) = centers_X(i) + binsize_X
        bins_Y(i, 0) = centers_Y(i) - binsize_Y
        bins_Y(i, 1) = centers_Y(i) + binsize_Y
  end do;i
 ;print(bins_X+" *** "+bins_Y)

  print("Generating colormap indices......");
  scatter_COL = new(dimsizes(x), typeof(x));
  scatter_COL = 0
  do i = 0,dimsizes(x)-1
        if ((mod(i,onepercent) .eq. 0).and.(i.le.50))
            print("..........")
        end if
        
        last_higher_X := UNDEF
        last_lower_X  := UNDEF
        id_X          := UNDEF
        c_X = x(i)
         
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
            end if
        end if
        if (last_lower_Y.ne.UNDEF)
            id_Y = last_lower_Y
        else
            if (last_higher_Y.ne.UNDEF)
                id_Y = last_higher_Y
            end if
        end if 

        scatter_COL(i) = values(toint(id_X), toint(id_Y));
       
    end do;i
    print("***** Min Max value of color indicies *****")
    printMinMax(scatter_COL,True)
    print("*******************************************")


    print("***** get colors ******")
    cmap    = read_colormap_file(mapname)
    subcmap = cmap(2:,:)
    szcmap  = dimsizes(subcmap)
    ncolor  = szcmap(0)
    
    if ncolor.lt.toint(max(scatter_COL)) then
       print(" the color indicies exceed the maxmum of the color map")
       exit
    else 
       colors=subcmap(toint(scatter_COL),:)     
    end if
    return(colors)
end    
