
function main ()
clc;
clear all;
%e.g.
   %pthin    = '/data/pkgroup2/zhang/stratus/';  
   %filename = 'OS_Stratus_2000-2010_D_MLTS-1hr.nc'; 
    varName  = 'SW';
     
     pthin        = '/data/pkgroup2/zhang/stratus/'; % data location
     pthout       = [pwd,'/'];
     filelist     = dir([pthin,'*MLTS*.nc']);
    if ~isempty(filelist) 
        nfile    = length(filelist)         
        for ifile    = 1:nfile
           filename  = [pthin,filelist(ifile).name];
           disp(filename)
           if ifile==1
                ncdisp(filename)
           end
           [data] = read_netcdf_v0(filename,varName);
           odata  = data.img;
           dateV  = data.dateV; % format [yyyy mm dd HH MM SS];
           if ifile==1
                dlmwrite([pthout,'datevector.txt'],dateV(:,1:5),'delimiter','\t') % only output yyyymmdd HH:MM;% use tab as the delimiter;
                oFile = [pthout,varName,'.dat'];                          % output as a unformatted binary file;
                disp(oFile);
                ofid  = fopen(oFile,'w');
            else
                dlmwrite([pthout,'datevector.txt'],dateV(:,1:5),'-append','delimiter','\t')
           end
           fwrite(ofid, odata, data.type); 
           if ifile==nfile
                fclose(ofid);
           end
 
        end
        else
        disp('did not find the file');keyboard;    
    end     
    
   keyboard
end


%----------------------------------------------------------------------
function [data] = read_netcdf_v0(filename,varName )
% Input Variables
%       filename: String; e.g.[path,filename] 
%                 fileName = [/data/pkgroup2/xiaolei/SWATH/Pwater/','pr_wtr.eatm.2005.nc'];
%       varName: String; The variable in NetCDF data;
% Output Variables
%        data: Structure  
%        data.name: string; name of data;
%        data.time: double; the time of data (added the reference)
%        data.dateV: array; The date vector of data
%        data.type : string: data type

   datain   = ncread(filename,varName); % readin the data needed
   timenum  = ncread(filename,'TIME');  % time % double x/86400(sec)
   timeunit = ncreadatt(filename,'TIME','units'); % get the time attribute of units 
   reft     = datenum(timeunit(12:end),'yyyy-mm-dd HH:MM:SS') % get the reference time
   timenum  = timenum+reft;
   dateV    = datevec(timenum);  % get the date vector
  
   
   data.name = varName;
   data.time = timenum;
   data.dateV= dateV;
   data.img  = datain;
   data.type = class(datain);

%keyboard
end







