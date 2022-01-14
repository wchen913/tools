function main()
clear all;clc;
addpath('/data/srb1/wchen/tools/m_fx/','-end')
yyyy   = 2004;%2007;%2000;%

dyntFlag = 'Allday';%'night'; %'day';% if to mask nighttime values
outins  = 'no'; % if output 3min data
outhour  = 'yes';% if output inst hourly data

stid   = 'sxf';%'tbl';%'psu';% 'dra';%'bon';%'gwn';%'fpk';%

if yyyy<2009
    win=10;winstrt=1;
else
    win=30;winstrt=1;
end
EMIS   = 0.97;
%pthin  = '/data/ceop4/srb/SURFRAD/2000/';
%pthin  = ['/data/ceop4/srb/SURFRAD/',num2str(yyyy),'/'];
pthin  = ['/data/srb3/wchen/Groundtruth/SURFRAD/',upper(stid),'/'];
pthout = '/data/srb3/wchen/LST/SURFRAD_obtained/';
 
 %*** column 17 : dw_ir; column 23: up_ir
 [dw_ir dynt]= extract_var(pthin,stid,yyyy,17); 
 [up_ir dynt]= extract_var(pthin,stid,yyyy,23);
 %calculate LST
 const = 5.670373e-8; %Stefan-Boltzmann constant. 
 
 exps1 = up_ir-(1-EMIS)*dw_ir;
 exps2 = const*EMIS;
 exps  = exps1/exps2;
 LST   = exps.^0.25;
 if strcmpi(outins,'yes')
%keyboard
 %output instantaneous 3min data
 ofname = [pthout,num2str(yyyy),'_LST_SURFRAD_',upper(stid),'_Allday_1min.dat'];%3min before 2009
 LST   = LST(:);
 LST(find(isnan(LST)))= -9999.9;
 fid   = fopen(ofname,'w');
 fwrite(fid,LST,'float32');
 fclose(fid) ;
 end%out3min
 %{
 [dw_rad dynt]= extract_var(pthin,stid,yyyy,9);  
 [up_rad dynt]= extract_var(pthin,stid,yyyy,11);
 [net_rad dynt]= extract_var(pthin,stid,yyyy,33);
 [net_ir dynt]= extract_var(pthin,stid,yyyy,35);
 [totalnet dynt]= extract_var(pthin,stid,yyyy,37);
 [diffuse dynt]= extract_var(pthin,stid,yyyy,15);
 temp=net_rad(1:10,17:21,128);
 line(1:50,temp(:),'color','b','LineWidth',2)
 hold
 temp=net_rad(1:10,17:21,219);
 line(1:50,temp(:),'color','r','LineWidth',2)
 hold
 temp=totalnet(1:10,17:21,128);
 line(1:50,temp(:),'color','g','LineWidth',2)
 hold
 temp=totalnet(1:10,17:21,219);
 line(1:50,temp(:),'color','black','LineWidth',2)
 hold
 %}
 %{
 figure(1)
 subplot(2,2,1);
 temp=dw_rad(1:10,17:21,128);
 line(1:50,temp(:),'color','c','LineWidth',2)
 hold
 temp=dw_rad(1:10,17:21,219);
 line(1:50,temp(:),'color',[1,0.4,0.6],'LineWidth',2)
 set(gca,'LineWidth',2,'fontsize',14)
 legend({'SW\downarrow 128','SW\downarrow 219'},'Box','off','fontsize',12)

 subplot(2,2,2);
 temp=dw_ir(1:10,17:21,128);
 line(1:50,temp(:),'color','m','LineWidth',2)
 hold
 temp=dw_ir(1:10,17:21,219);
 line(1:50,temp(:),'color','y','LineWidth',2)
 set(gca,'LineWidth',2,'fontsize',14)
 legend({'LW\downarrow 128','LW\downarrow 219'},'Box','off','fontsize',12)
 
 subplot(2,2,3);
 temp=LST(1:10,17:21,128);
 line(1:50,temp(:),'color','r','LineWidth',2)
 hold
 temp=LST(1:10,17:21,219);
 line(1:50,temp(:),'color','b','LineWidth',2)
 set(gca,'LineWidth',2,'fontsize',14)
 legend({'SKT 128','SKT 219'},'Box','off','fontsize',12)
%    legend({'LW\downarrow 128','LW\downarrow 219','SW\downarrow 128','SW\downarrow 219','SKT 128','SKT 219'},...
%           'fontsize',12)
 %}
 %
 if strcmpi(dyntFlag,'day')
     LST(dynt==0)=NaN;
 end
 if strcmpi(dyntFlag,'night')
     LST(dynt==1)=NaN;
 end 
 [nmin nhour nday]=size(LST);
 tmp   = nan(nhour,nday);
 %inst hourly data
 for iday = 1:nday
  for ihour = 1:nhour
   nngt    =  length(find(isnan(LST(winstrt:win,ihour,iday))));
   if nngt<3 
       tmp(ihour,iday)=nanmean(LST(winstrt:win,ihour,iday));
   end
  end
 end
 clear LST
 LST   = squeeze(tmp);
 clear tmp
 disp(size(LST))
%  keyboard
 LST   = LST(:);
 LST(find(isnan(LST)))= -9999.9;
 if strcmpi(outhour,'yes')
   if strcmpi(dyntFlag,'day') || strcmpi(dyntFlag,'night')
%     ofname = [pthout,num2str(yyyy),'_LST_SURFRAD_',upper(stid),'_wins',num2str(winstrt),'_day.dat'];
      ofname = [pthout,num2str(yyyy),'_LST_SURFRAD_',upper(stid),'_',dyntFlag,'.dat'];
   else
%     ofname = [pthout,num2str(yyyy),'_LST_SURFRAD_',upper(stid),'_wins',num2str(winstrt),'_Allday.dat'];
      ofname = [pthout,num2str(yyyy),'_LST_SURFRAD_',upper(stid),'_Allday.dat'];
   end %dyntFlag
   
 fid   = fopen(ofname,'w');
 fwrite(fid,LST,'float32');
 fclose(fid) ;
 end %outhour
end
%************************************************************************
function [dataout datadynt]=extract_var(pthin,stid,yyyy,Cn)
%************************************************************************
%---------------------------------------------- 
% pthin -- input data path
% stid  -- station id
% yyyy  -- year
% Cn-- column number
%----------------------------------------------
yearstr    = num2str(yyyy);
yystr      = yearstr(3:4);
if yyyy<2009
   tRes    = 3;
else
   tRes    = 1;
end
if leapyear(yyyy)
    ndays  = 366;
else
    ndays  = 365;
end

nhor    = 24;
nmin    = 60/tRes;
dataout = nan(nmin,nhor,ndays);
datadynt= nan(nmin,nhor,ndays); 
for jday = 1:ndays
   %disp(jday)
    dystr    = num2str(jday,'%03d');
    filename =[pthin,stid,yystr,dystr,'.dat'];
    if exist(filename)
        datain   = importfile(filename);  
        tmp      = datain(:,Cn); 
        tmp(tmp<-9000.) = NaN;
        hor      = datain(:,5);
        mint     = datain(:,6);
        zen      = datain(:,8);
        if length(tmp)~=nhor*nmin 
            disp(['day of year ',num2str(jday),' has missing time'])
        end
        for iline=1:length(tmp)
             ihor=hor(iline)+1;
             imin=mint(iline)/tRes+1;
             %disp(ihor);disp(imin);
             dataout(imin,ihor,jday)=tmp(iline);
             if zen(iline)<=87.5
                 datadynt(imin,ihor,jday)=1;
             else
                 datadynt(imin,ihor,jday)=0;
             end
        end %for ilne
        
    else
        disp([filename,' does not exist'])
    end % if exist
 
end % for jday
end



function data=importfile(fileToRead)
%IMPORTFILE(FILETOREAD1)
%  Imports data from the specified file
%  FILETOREAD1:  file to read

%  Auto-generated by MATLAB on 04-Aug-2015 14:38:00

DELIMITER = ' ';
HEADERLINES = 2;

% Import the file
newData = importdata(fileToRead, DELIMITER, HEADERLINES);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData);
data = newData.data ;

end

