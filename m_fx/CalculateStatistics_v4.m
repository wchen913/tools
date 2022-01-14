function [bias,avg,rms,stddev,stdbfr,cof,npts,dof,outline]=Calculate_statistics(x,y,optDim,optOutlie)
 % Calculate Total Statics       
 % inputs-- x,y,optDim,optOutline
 % output-- bias : bias
 %          avg  : x mean
 %          rms  : root mean square error
 %          std  : standard deviation
 %          cof  : correlation coefficient
 %          npts : degree of freedom without removing outlies
 %          dof  : degree of freedom
 %          dif  : difference between x and y
 %          stdbfr : std before removing outlies;
 %% -------------------- Calculate Total Statics  
  
   if strcmpi(optOutlie,'no')
    dif = y-x; 
    stddev  = squeeze(nanstd(dif,0,optDim));
    stdbfr = stddev;
    dof  = length(find(~isnan(dif)));
    npts = dof;
    outline=[];
   elseif strcmpi(optOutlie,'yes')
    dif  = y-x;  
    npts = length(find(~isnan(dif)));
    stddev  = squeeze(nanstd(dif,0,optDim));
    stdbfr = stddev;
    outline = abs(dif) > 3*stddev;
    y(outline) = NaN;
    x(outline) = NaN;
    clear dif
    dif = y-x;
    stddev = squeeze(nanstd(dif,0,optDim));
    dof = length(find(~isnan(dif)));
   else
       disp('--- Invalid removeOutliers value!');keyboard;
   end
  
   bias  = nanmean(dif);
   rms  = sqrt(nanmean(dif.^2));
   avg = nanmean(x);
   
   nanRoiIdx =~isnan(x)&~isnan(y);
   cof   = corrcoef(x(nanRoiIdx),y(nanRoiIdx));
   cof  = cof(1,2);
   
%------------- end Calculate Total Statics

 end

