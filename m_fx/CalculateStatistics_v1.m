function [bias,avg,rms,std,cof,npts]=Calculate_statistics(x,y,opDim)
        
   
 %% -------------------- Calculate Total Statics  
   diff = y-x; 
   std  = squeeze(nanstd(diff,0,opDim));
   npts = length(find(~isnan(diff)));
   bias  = nanmean(diff);
   rms  = sqrt(nanmean(diff.^2));
   avg = nanmean(x);
   
   nanRoiIdx =~isnan(x)&~isnan(y);
   cof   = corrcoef(x(nanRoiIdx),y(nanRoiIdx));
   cof  = cof(1,2);
   
%------------- end Calculate Total Statics

 end

