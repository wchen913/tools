%==========================================================================
function dataout=landseamask_1deg(data,LatLim,LonLim,Res,FillValue,Opt)
%==========================================================================
% datain : input data 
% LatLim : Latitude limitations [latS LatN]
% LonLim : longitude limitations [LonW LonE]
% Res    : Resolution of the land-sea and input data 1deg or 0.05 deg
% FillValue : The vale fill the water or land grid
% Opt    : Options for land mask ore ocea mask
%--------------------------------------------------------------------------
 dataout = data;
 if Res==1
   
  nsfcLat = 180; % -89.5~89.5
  nsfcLon = 360; % -179.5~179.5
  sfc     = load('/data/crash/wchen/mask/SurfaceType_1deg.dat');
  sfcType   = sfc(:,4); sfcType  = reshape(sfcType,[nsfcLon nsfcLat]);
  sfcLat2D  = sfc(:,1); sfcLat2D = reshape(sfcLat2D,[nsfcLon nsfcLat]);
  sfcLon2D  = sfc(:,2); sfcLon2D = reshape(sfcLon2D,[nsfcLon nsfcLat]);
 
  sfcLat1D = squeeze(sfcLat2D(1,:)); sfcLon1D = squeeze(sfcLon2D(:,1));
  indLatS  = find(sfcLat1D==LatLim(1));  
  indLatN  = find(sfcLat1D==LatLim(2));
  indLonW  = find(sfcLon1D==LonLim(1));   
  indLonE  = find(sfcLon1D==LonLim(2));
 
  lsm      = sfcType(indLonW:indLonE,indLatS:indLatN);
  if strcmpi(opt,'ocean')
      dataout(lsm==0) = FillValue;
  elseif strcmpi(opt,'land')
      dataout(lsm==1) = FillValue;
  end
 end
 
end
