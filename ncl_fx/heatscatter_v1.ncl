;*************************************************
; heatscatter.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors
;
;*************************************************
;This function is to generate density scatter plot color map
undef("heatscatter")
function heatscatter(x[*]:numeric,y[*]:numeric,numbins:numeric,limts[*],opt)
local UNDEF,pdf2,onepercent,numbers,values,\
      centers_X,centers_Y,binsize_X,binsize_Y,\
      bins_X,bins_Y,i,scatter_COL,scatter_Num,\
      last_lower_X,last_lower_Y,last_higher_X,last_higher_Y,\
      last_lower_X_inds, last_higher_X_inds,\
      last_lower_Y_inds, last_higher_Y_inds,\
      id_X,id_Y,c_X,c_Y,opt
begin
 
  UNDEF  = -999
  if opt then
  opt@binx_min = limts(0)
  opt@biny_min = limts(0)
  opt@binx_max = limts(1)
  opt@biny_max = limts(1)
  end if
  pdf2       = pdfxy(x,y,numbins,numbins,opt)
  onepercent = round(dimsizes(x) / 100,3)
  print("onepercent= "+onepercent)
  
   numbers    = tofloat(ceil(pdf2*onepercent))
   values     = tofloat(pdf2)
  print("****** Min Max of Values *******")
  printMinMax(values, True) 
  printMinMax(numbers,True) 
  print("********************************")
   
  centers_X = tofloat(pdf2@binx_center)
  centers_Y = tofloat(pdf2@biny_center)    

  binsize_X = abs(centers_X(1) - centers_X(0)) / 2
  binsize_Y = abs(centers_Y(1) - centers_Y(0)) / 2

  bins_X = new((/numbins, 2/),typeof(x))
  bins_Y = new((/numbins, 2/),typeof(y))
  bins_X = 0
  bins_Y = 0

  last_higher_X = 0
  last_higher_X@_FillValue = UNDEF
  last_lower_X  = 0
  last_lower_X@_FillValue  = UNDEF 
  
  last_higher_Y = 0
  last_higher_Y@_FillValue = UNDEF
  last_lower_Y  = 0
  last_lower_Y@_FillValue  = UNDEF 

  id_X = 0
  id_X@_FillValue  = UNDEF
  id_Y = 0
  id_Y@_FillValue  = UNDEF
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
  scatter_Num = scatter_COL
  do i = 0,dimsizes(x)-1
        if ((mod(i,onepercent) .eq. 0).and.(i.le.50)) then
            print("..........")
        end if
        
        last_higher_X = UNDEF
        last_lower_X  = UNDEF
        id_X          = UNDEF
        c_X = x(i)
        
        last_lower_X_inds := ind(c_X .ge. bins_X(:,0))
        last_lower_X_inds@_FillValue  = UNDEF
        if (.not.all(ismissing(last_lower_X_inds))) then
            nlast_lower_X = dimsizes(last_lower_X_inds )
            last_lower_X  = last_lower_X_inds(nlast_lower_X-1)            
        else
            last_higher_X_inds := ind(c_X .le. bins_X(:,1))
            last_higher_X_inds@_FillValue = UNDEF
            if (.not.all(ismissing(last_higher_X_inds))) then
                last_higher_X = last_higher_X_inds(0)               
            end if 
        end if
       
        if (.not.ismissing(last_lower_X)) then
            id_X = last_lower_X
        else
              if (.not.ismissing(last_higher_X)) then
                id_X = last_higher_X
            end if
        end if
         
        last_higher_Y = UNDEF
        last_lower_Y  = UNDEF
        id_Y          = UNDEF
        c_Y = y(i)
        last_lower_Y_inds := ind(c_Y .ge. bins_Y(:,0)) 
        last_lower_Y_inds@_FillValue = UNDEF
        if (.not.all(ismissing(last_lower_Y_inds))) then
            nlast_lower_Y=dimsizes(last_lower_Y_inds)
            last_lower_Y := last_lower_Y_inds(nlast_lower_Y-1)            
        else
            last_higher_Y_inds := ind(c_Y .le. bins_Y(:,1))
            last_higher_Y_inds@_FillValue = UNDEF
            if (.not.all(ismissing(last_higher_Y_inds))) then
                last_higher_Y := last_higher_Y(0)
            end if
        end if
        if (.not.ismissing(last_lower_Y)) then
            id_Y = last_lower_Y
        else
            if (.not.ismissing(last_higher_Y)) then
                id_Y = last_higher_Y
            end if
        end if 
       ;print(i+"---"+(id_X)+" Index "+(id_Y)+"   ~"+numbers(toint(id_X), toint(id_Y)))
        if (.not.ismissing(id_X)) .and.(.not.ismissing(id_Y)) then
            scatter_COL(i) = values(toint(id_X), toint(id_Y))
            scatter_Num(i) = numbers(toint(id_X), toint(id_Y))
        end if
    end do;i
   ;print(scatter_COL)    
   ;print(round(scatter_COL,3))
    
     
      scatter_COL@scatter_num = scatter_Num 
      
    return(scatter_COL)
end    
