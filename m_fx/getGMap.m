
function  [nLons,dLons,lonZero,EqAeLatLonID,EqAgLonLimit, GMap] =...
                                                     getGMap(AngRes)
%GMap maps (lat,lon) to grid index; start at lat=-90,lon=0. 

      % AngRes in degrees.
      MaxLat = 180/AngRes;
      MaxLon = 360/AngRes;

      D2R    = pi/180;
      Rearth = 6371.2;

      
      % ** CALCULATE AREA OF EQUATORIAL CELL
      CellH0 = Rearth * sin( AngRes*D2R );
      BeltA0 = 2.0 * pi * Rearth * CellH0;
      CellA0 = BeltA0 / 360 * AngRes;
      
      LatV   = 0:AngRes:90; %--- need half of them only.
      hiLat  = LatV(2:end  );
      loLat  = LatV(1:end-1);
      CellHV = Rearth * ( sin(hiLat*D2R) - sin(loLat*D2R) );
      BeltAV = 2.0*pi * Rearth * CellHV;      
      hfNumCells = round( BeltAV / CellA0 );


  
      %-- equal-area parameters
      nLons   = [fliplr(hfNumCells), hfNumCells]';
      dLons   = 360 ./ nLons;
      lonZero = cumsum([0;nLons(1:end-1)]);

      MaxCell = lonZero(end)+nLons(end);
      EqAeLatLonID = nan(MaxCell,2); %[lat,lon]
      EqAgLonLimit = nan(MaxCell,2); %[west,east]
      ig = 0;
      for ilat = 1:length(nLons)
      for ilon = 1:nLons(ilat)
         ig = ig+1;
         EqAeLatLonID(ig,1) = ilat;
         EqAeLatLonID(ig,2) = ilon;  
         dd = dLons(ilat)/AngRes;
         EqAgLonLimit(ig,1) = round( (ilon-1)*dd ) + 1; %west most eq-agnle box id within ig
         EqAgLonLimit(ig,2) = round( ilon*dd ); %eastmost eq-angle box id that's within ig.
      end
      end



      %-- equal-angle to equal-area mapping
      CellWM = repmat(dLons, [1,MaxLon]);
      LM     = repmat( [0:AngRes:360-AngRes] + AngRes/2, [MaxLat,1] );
      CMap   = floor( LM ./ CellWM ) + 1; % ceil() is ---*, floor()+1 is *---
      tV     = cumsum([0,max(CMap')]); %[361,720]
      tM     = repmat(tV(1:end-1)', [1,MaxLon]);
      GMap   = CMap + tM;

end %-------------------------------------------


