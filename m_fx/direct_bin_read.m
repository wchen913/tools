function data=direct_bin_read(FileName,N,dataType)
% readin direct binary file
% input 
%   FileName (string)-file name 
%   N (numeric) - total size of the data, e.g. N=nlat*nlon*ntime
%   dataType (string) - type of data
% output
%   data
fid    = fopen(FileName,'r');
data   = fread(fid,N,dataType);
fclose(fid);
end
