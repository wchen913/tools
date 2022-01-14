%=====================================================================================
function data_out = merge_bin_dailydata(pth_in,filenames,yyyy,months,ndimsize,dataType,option)%
%=====================================================================================
% merge daily data
% the name of the data should in same format and in sequential. eg.*yyyymm*
% one record contanis one month daily data

global FillValue
filelist   = dir([pth_in,filenames]);
nfiles     = length(filelist);

if nfiles==0 
      disp('---getData(): Empty file list!')
      keyboard     
end
ifl=1;
      for iyr=yyyy
         if iyr==2002
             months=[7:12];
         elseif iyr==2010
             months=[1:6];
         else
             months=[1:12];
         end
         for imm=months
	    year = iyr;
        mm   = imm;
	    filename = filelist(ifl).name;
            disp(filename)
%             disp(year);disp(iyr);disp(mm);disp(imm);
    	    if mm==1 || mm==3 || mm==5 || mm==7 || mm==8 || mm==10 || mm==12
       		ntime = 31;
   	    elseif mm==4 || mm==6 || mm==9 || mm==11
       		ntime  = 30;
            elseif mm==2 && leapyear(year)
       		ntime  = 29;
            else
       		ntime  = 28;
    	    end % endif mm 
%             disp(year);disp(mm);disp(ntime)
   	    FileName = [pth_in,filename];
   	    dimsN    = [ndimsize ntime];   
   	    data     = direct_bin_read(FileName,prod(dimsN),dataType);
   	    if FillValue < 0  
        	 data(data<=FillValue) =  NaN;        
    	    elseif FillValue > 0
       		 data(data>=FillValue) =  NaN;    
    	    end % endif FillValue
   	    data  = reshape(data,dimsN);
  	    if ifl==1
     		data_out = data;     
     		mdim = ndims(data_out);  %cat dim  
	    else   
     		data_out = cat(mdim,data_out,data);
  	    end %endif ifl
 	    ifl=ifl+1;
	  end %endfor imm
      end % endfor iyr 

end % endif nfiles


% tmp = data_out(:,:,1);
% imagesc(tmp);
% keyboard


