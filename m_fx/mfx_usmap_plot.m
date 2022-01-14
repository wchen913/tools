function us_map_plt(figureid,data,clim)
% 
figure(figureid);clf('reset');

load usamtx;
hx=worldmap(map,refvec);%worldmap([25,50],[-125,-70])
setm(hx,'mapprojection','mercator',...
    'maplatlimit',[25 50],'maplonlimit',[-125,-70])
geoshow(map,refvec,'FaceColor','white');

load coast;plotm(lat,long,'k');
load conus;plotm(uslat,uslon,'k');plotm(statelat,statelon,'k');
clear lat long uslat uslon statelat statelon  

lat2d=data.sRET.lat;
lon2d=data.sRET.lon;
lst=double(data.sRET.lst);
glat=lat2d(1:1:end,1:1:end);clear lat2d;
glon=lon2d(1:1:end,1:1:end);clear lon2d;
glst=lst(1:1:end,1:1:end);clear lst;

s=pcolorm(glat,glon,glst);
demcmap(clim);
colormap jet
colorbar;
tightmap

end
