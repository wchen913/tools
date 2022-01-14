function [bias,avg,rms,std,stdbfr,cof,npts,dof,outline]=Calculate_statistics(x,y,optDim,optOutlie)
 % Calculate Total Statics       
 % inputs-- x,y,optDim,optOutline
 % output-- bias : bias
 %          avg  : x mean
 %          rms  : root mean square error
 %          std  : standard deviation
 %          cof  : correlation coefficient
 %          npts : degree of freedom without removing outlies
 %          dof  : degree of freedom
 %          diff : difference between x and y
 %          stdbfr : std before removing outlies;
 %% -------------------- Calculate Total Statics  
  
   if strcmpi(optOutlie,'no')
   diff = y-x; 
   std  = squeeze(nanstd(diff,0,optDim));
   stdbfr = std;
   dof  = length(find(~isnan(diff)));
   npts = dof;
   elseif strcmpi(optOutlie,'yes')
   dif  = y-x;  
   npts = length(find(~isnan(dif)));
   std  = squeeze(nanstd(dif,0,optDim));
   stdbfr = std;
%      keyboard
   outline = abs(dif) > 3*std;
   y(outline) = NaN;
   x(outline) = NaN;
   clear dif
   diff = y-x;
   std = squeeze(nanstd(diff,0,optDim));
   dof = length(find(~isnan(diff)));
   else
       disp('--- Invalid removeOutliers value!');keyboard;
   end
  
   bias  = nanmean(diff);
   rms  = sqrt(nanmean(diff.^2));
   avg = nanmean(x);
   
   nanRoiIdx =~isnan(x)&~isnan(y);
   cof   = corrcoef(x(nanRoiIdx),y(nanRoiIdx));
   cof  = cof(1,2);
   outline=[];
%------------- end Calculate Total Statics

 end

