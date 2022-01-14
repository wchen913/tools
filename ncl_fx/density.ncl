; Scatter plot with color indicating data density
;
; USAGE:
;   out = scatplot(x,y,method,radius,N,n,po,ms)
;   out = scatplot(x,y,dd)
;
; DESCRIPTION:
;   Draws a scatter plot with a colorscale 
;   representing the data density computed 
;   using three methods
;
; INPUT VARIABLES:
;   x,y - are the data points
;   method - is the method used to calculate data densities:
;       'circles' - uses circles with a determined area 
;               centered at each data point
;       'squares' - uses squares with a determined area 
;               centered at each data point
;       'voronoi' - uses voronoi cells to determin data densities
;               default method is 'voronoi'
;   r~radius - is the radius used for the circles or squares
;       used to calculate the data densities if
;       (Note: only used in methods 'circles' and 'squares'
;           default radius is sqrt((range(x)/30)^2 + (range(y)/30)^2)
;   N - is the size of the square mesh (N x N) used to  
;       filter and calculate contours
;       default is 100
;   optoutput - select return results
; OUTPUT VARIABLE:
;   out - structure array that contains the following fields:
;       dd - unfiltered data densities at (x,y)
;       ddf - filtered data densities at (x,y)
;;Copy-Left, Alejandro Sanchez-Barba, 2005
;;Converted from MATLAB by Wen Chen 2018
load "/data/srb1/wchen/tools/ncl_fx/substring.ncl"
undef("density")
function density(x[*]:numeric,y[*]:numeric,methodname:string,r:numeric,N:numeric,optoutput:numeric,ncolor:numeric)
local method,Ld,dd,ii,k,area,xi,yi,zi1d,zi,indc
begin 
    method = substring(methodname,0,1);

 ;--------- Caclulate data density ---------
;dd = datadensity(x,y,method,radius); 
Ld = dimsizes(x)
dd = new(Ld,typeof(x))

    if method .eq. "sq"  ;---- Using squares ----
        do k=0,Ld-1
            ii := ind(x.gt.(x(k)-r) .and. x.lt.(x(k)+r).and. y.gt.(y(k)-r) .and. y.lt.(y(k)+r))
            if .not.all(ismissing(ii)) then
                dd(k) = dimsizes( ii );
            else
                dd(k) = 0
            end if
        end do ;k
        area = (2*r)^2 
        dd = dd/area 
    end if;"sq"
    if method.eq. "ci"
        do k=0,Ld-1
            ii := ind((sqrt((x-x(k))^2 + (y-y(k))^2) ).lt.r)
            if .not.all(ismissing(ii)) then
                dd(k) = dimsizes( ii );
            else
                dd(k) = 0
            end if
        end do ;k
        area = get_pi(typeof(r))*r^2;
        dd = dd/area
    end if;"ci"  
 
;------------- Gridding -------------------
 
xi = conform_dims((/N,N/),fspan(min(x),max(x),N),1);
yi = conform_dims((/N,N/),fspan(min(y),max(y),N),0);
nnpntinit(x,y,dd)
zi1d = nnpnt(ndtooned(xi),ndtooned(yi))
zi   = onedtond(zi1d,(/N,N/))
nnpntend() 

indc = round((dd-min(dd))/(max(dd)-min(dd))*(ncolor-1),3);+1
 
if optoutput.eq.0 then
    dd@indc = indc
    return(dd)
else
    zi@den = dd
    zi@indc= indc
    return(zi)
end if
end


