function data = sequential_bin_read(FileName,Position,N,dataType)
% readin sequetial binary file
% input 
%   FileName (string)-file name 
%   Position (numeric)- the recl of the data
%   N (numeric) - total size of the data, e.g. N=nlat*nlon*ntime
%   dataType (string) - type of data
% output
%   data
 fid    = fopen(FileName,'r');
 fseek(fid,Position,'bof');
 data = fread(fid,N,dataType);  
 fclose(fid);
end