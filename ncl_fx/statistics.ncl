load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/substring.ncl"
undef("xyStatistics")
function xyStatistics (x[*]:numeric,\
                       y[*]:numeric,\
                       nStd:numeric,\
                       optOutlier:logical,\
                       opt)
local diff,Corr,Bias,Std,RMSE,N,dof,inds,UNDEF                    
begin
    UNDEF   = x@_FillValue
    diff    = y-x
  	Corr    = escorc(y,x);esccr(x,y,0)
    if Corr.ge.1. then
        Corr    = 0.99
    end if
  	Bias = avg(diff)
  	N    = num(.not.ismissing(diff))
    dof  = N
  	Std  = stddev(diff)
  	RMS  = sqrt(avg(diff^2) )     
	if optOutlier then
        inds	   = ind(abs(diff).gt.(nStd*Std))     
        if .not.all(ismissing(inds)) then
            x(inds) = x@_FillValue
            y(inds) = y@_FillValue
            diff    = y-x            
            Corr = escorc(y,x);esccr(x,y,0)
            Bias = avg(diff)
            N    = num(.not.ismissing(diff))
            Std  = stddev(diff)
            RMS  = sqrt(avg(diff^2) )   	   
        end if ;if .not.all(ismissing(inds)) then
    end if ; if optOutlier 
    diff@Corr = Corr
    diff@RMS  = RMS
    diff@Bias = Bias
    diff@Std  = Std
    diff@dof  = dof
    diff@N    = N
    
    return(diff)
end
    