;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~ Data Density ~~~~~~~~~~~~~~
;Computes the data density (points/area) of scattered points
;Striped Down version
;
; USAGE:
;   dd = datadensity(x,y,method,radius)
;
; INPUT:
;   (x,y) -  coordinates of points
;   method - either 'squares' or 'circles'          
;   radius - Equal to the circle radius or half the square width
undef("datadensity")
function datadensity(x[*]:numeric,y[*]:numeric,method:string,r:numeric)
local Ld,dd,ii,k,area 
begin
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
return(dd)
end
