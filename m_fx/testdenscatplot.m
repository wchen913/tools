%  x=random('Normal',282,14,500,1);
%  y=random('Normal',278,12,500,3);
pth = '/data/srb1/wchen/WORK/others/Zhang/weller/';
fid = fopen([pth,'SW_daily.data'],'r')
x=fread(fid,2526,'float');
fclose(fid)

y=ncread([pth,'SW_CFSR_daily.nc'],'ssda');
y=double(y');
% r=sqrt((range(x)/30)^2+(range(y)/30)^2)

z = denscatplot(x,y,'circles',30,30,5,1,10)
keyboard