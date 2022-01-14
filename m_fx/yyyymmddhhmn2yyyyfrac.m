function yearFrac = yyyymmddhhmn2yyyyfrac(yyyy,mm,dd,hh,mn,Opt)
% Convers the date to year.frac
% input numeric yyyy,mm,dd,hh,mn,Opt 
% output numeric yearFrac (yyyy.frac)
% Opt-Options 1 to determine the year is leap year or not
%             2 days of a year = 366;
%             3 days of a year = 365;
%             4 days of a year = 360;
% con-contains [days of a year (365 or 366 or 360),
%               secons of a day (24*60*60=86400),
%               seconds of an hour (60*60),
%               sencons of a minute (60)]
% doy- day of  year
% yearsec-seconds of a year
% daysec-sencods of a day

addpath('/homes/metofac/wchen/tools/m_fx','-end');
switch Opt
    case 1 
if leapyear(yyyy)
 con = [366 86400 3600 60] ;
else
 con= [365 86400 3600 60] ;  
end
    case 2
        con = [366 86400 3600 60] ;
    case 3
        con = [365 86400 3600 60] ; 
    case 4 
        con = [360 86400 3600 60] ; 
end

doy      = date2doy(datenum(yyyy,mm,dd));
yearsec = con(1)*con(2);
daysec  = (doy-1)*con(2)+hh*con(3)+mn*con(4);
yearFrac = yyyy+daysec/yearsec;
end