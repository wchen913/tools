%e.g.
%LST_Day_CMG = hdfread('/data/srb3/wchen/Satellite/MODIS/monthly/MOD11C3/MOD11C3.A2004001.006.2015213011324.hdf', 'MODIS_MONTHLY_0.05DEG_CMG_LST', 'Fields', 'LST_Day_CMG');
clear all;
yyyy=2004:2005;

fpath='/data/srb3/wchen/Satellite/MODIS/monthly/MOD11C3/';
%fptn  = [fpath,'MOD11C3.A',num2str(yyyy),'*.hdf']
fptn  = [fpath,'MOD11C3.A*.hdf'];
fList = dir(fptn);
 
nFiles = length(fList);
   if nFiles==0
      disp('---getMOD11Data(): Empty file list!')
      %keyboard
      mod11=[];
      return
   end
 %-- sort the arraies
   years = nan(nFiles,1);
   doys = nan(nFiles,1);
  
   for i=1:nFiles
     years(i) = str2num(fList(i).name(10:13)); 
     doys(i)  = str2num(fList(i).name(14:16));
       
   end

   lineT = years*1000+doys;
   [lineT,ix] = sort(lineT);
   fList = fList(ix);
   
   
    for ifl = 1:length(fList)

      fileName = fList(ifl).name;
      disp(fileName)
      fullName = [fpath,'/',fileName];
 
      lstM = hdfread(fullName, 'LST_Day_CMG');
      qcdM = hdfread(fullName, 'QC_Day');
      sttM = hdfread(fullName, 'Day_view_time');
      staM = hdfread(fullName, 'Day_view_angl');
%       staM = hdfread(fullName, 'View_angle');
% 
      lstM  = double(lstM)*0.02;
      sttM  = double(sttM)*0.2;      
      staM  = double(staM)*1+(-65);
      lstM(qcdM~=0)=NaN;
      imagesc(lstM)

        keyboard
%       end
   end

   
   