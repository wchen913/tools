clear all;
figure;
load usamtx;
hx=worldmap(map,refvec);%worldmap([25,50],[-125,-70]);
%getm(gca,'MapProjection')
%setm(gca,'MapProjection','mercator')
setm(hx,'mapprojection','mercator',...
    'maplatlimit',[25 50],'maplonlimit',[-125,-70])
geoshow(map,refvec,'FaceColor','white');
% keyboard
% OR
% axesm('MapProjection','mercator',...
%       'MapLatLimit',[25,50],'MapLonLimit',[-125 -75],...
%       'AngleUnits','degrees',...
%       'parallellabel','on');
%   framem;
load coast;
plotm(lat,long,'k');
load conus;
plotm(uslat,uslon,'k');
plotm(statelat,statelon,'k');
%keyboard
data=load('/aosc/jetstor/ytma/dev3/RTTOV/inverse2/data/out/G12_tp4_2004_07_1_1815.dat_RET.mat');
lat2d=data.sRET.lat;
lon2d=data.sRET.lon;
lst=double(data.sRET.lst);
glat=lat2d(1:1:end,1:1:end);
glon=lon2d(1:1:end,1:1:end);
glst=lst(1:1:end,1:1:end);
%keyboard
%contourfm(glat,glon,glst,280:0.5:325,'LineStyle','none')
s=pcolorm(glat,glon,glst);
demcmap([280 325]);
colormap jet
colorbar;
tightmap
