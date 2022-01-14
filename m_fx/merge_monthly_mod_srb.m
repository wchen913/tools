
%=====================================================================================
function data_out = merge_bin_monthlydata(pth_in,filenames,dimsizes,dataType,option)%
%=====================================================================================
% merge monthly data
% the name of the data should in same format and in sequential. eg.*yyyymm*  
% input variables
% pth_in : the location of input files
% finemaes: name of files (contain "??" or "*")
% dimsizes: dim size of input data 
% dataType: type of input data
% option: option not used yet
%-------------------------------------------------------------------------%
global FillValue
filelist   = dir([pth_in,filenames]);
nfiles     = length(filelist);
option     =''; 
if nfiles==0 
      disp('---getData(): Empty file list!')
      keyboard     
end
fcnt=1;
for ifl = 1:nfiles
 
    filename = filelist(ifl).name;
    disp(filename)
 
    FileName = [pth_in,filename];
    
    data = direct_bin_read(FileName,prod(dimsizes),dataType);
    if FillValue < 0
        MissValue = FillValue+9;  
        data(data<MissValue) =  NaN;
        
    elseif FillValue > 0
        data(data>=FillValue) =  NaN;    
    end
   data  = reshape(data,dimsizes);
  if fcnt==1
     data_out = data;  
     merge_dim = ndims(data_out)+1;
  else
     data_out = cat(merge_dim,data_out,data);
  end
  fcnt=fcnt+1;
end


% tmp = data_out(:,:,1);
% imagesc(tmp);
% keyboard

end
