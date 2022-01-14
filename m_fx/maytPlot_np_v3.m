

function [varargout] = maytPlotingFunc_np_v2( pCmd, varargin )
%
% 131108: output axhdl array which is the size of np+1 to return all
%         axes created in the figure.
% 130701: add 'showUSCounty' option to show county boundaries.
%         the comand need a boundingbox array as input to determine
%         which counties to draw.
% 130614: modified the interface, it more flexiable now!
%         %subplot_1_cmds = {{},{},...}
%         %subplot_1_cmds = {{},{},...}
%         %pCmd = { subplot_1_cmds,subplot_2_cmds }
%      
% 130607: add output of axis handle.
%
% * If your function accepts optional input strings and parameter 
%   name-value pairs, specify validation functions for the optional 
%   input strings. Otherwise, the Input Parser interprets the optional 
%   strings as parameter names.
%
% * To pass a value for the nth positional input, either specify 
%   values for the previous (n ? 1) inputs or pass the input as a 
%   parameter name-value pair.
%
% * Inputs that you add with addRequired or addOptional are positional
%   arguments. When you call a function with positional inputs, 
%   specify those values in the order they are added to the parsing
%   scheme. Inputs added with addParamValue are not positional.
%
%defaultFinish = 'glossy';
%validFinishes = {'glossy','matte'};
%checkFinish = @(x) any(validatestring(x,validFinishes));
%
%defaultColor = 'RGB';
%validColors = {'RGB','CMYK'};
%checkColor = @(x) any(validatestring(x,validColors));
%
%defaultWidth = 6;
%defaultHeight = 4;
%
%addRequired(p,'filename',@ischar);
%addOptional(p,'finish',defaultFinish,checkFinish);
%addOptional(p,'color',defaultColor,checkColor);
%addParamValue(p,'width',defaultWidth,@isnumeric);
%addParamValue(p,'height',defaultHeight,@isnumeric);                             pFuncArg, ...
%
   %--- persistent variables.
   persistent worldLat worldLon ...
              usLat usLon usStateLat usStateLon usGtLakeLat usGtLakeLon...
              usCntBBox usCntLat usCntLon
   

   %--- Default values.
   histFlag ='';
   scatterFlag = '';
   dftFig = 999;
   
   dftOrient = 'portraitMid';
   vldOrient = {'portratFull','portraitFull','portratMid','portraitMid','landscape'};
   checkOrient = @(x) any(validatestring(x,vldOrient));

   dftAnotStr  = '';
   dftPlotFlag = '';
   dftFigName  = '';
   dftStatistics  = {};
   dftlabelstr      = {};
   
   %--- Specify the input scheme.
   inps = inputParser;
   addRequired(inps, 'pCmd', @iscell);
   %addRequired(inps, 'pFuncArg', @(x) true);
   addOptional(inps, 'fignum', dftFig, @isnumeric);
   addOptional(inps, 'orient', dftOrient, checkOrient);
   addOptional(inps, 'anotStr', dftAnotStr, @iscell);
   addOptional(inps, 'plotFlag', dftPlotFlag, @ischar);
   addOptional(inps, 'figName', dftFigName, @ischar);
   addOptional(inps, 'Statistics', dftStatistics, @iscell);
   addOptional(inps, 'labelstr', dftlabelstr, @iscell);
   %---
   parse( inps, pCmd, varargin{:} );   



%keyboard

   %--- Ploting
   %
   figure(inps.Results.fignum);clf('reset')

   if strcmpi(inps.Results.orient, 'portratFull') ||...
      strcmpi(inps.Results.orient, 'portraitFull') %-- portrait full page.
      set(gcf, 'PaperPositionMode', 'manual');
      set(gcf, 'PaperUnits', 'inches');
      set(gcf, 'PaperPosition', [.25 .25 8 10.5]);
   elseif strcmpi(inps.Results.orient, 'portratMid') ||...
          strcmpi(inps.Results.orient, 'portraitMid')%-- Protrait middle part
      set(gcf, 'PaperPositionMode', 'manual');
      set(gcf, 'PaperUnits', 'inches');
      set(gcf, 'PaperPosition', [.25 2.5 8 6]);
   elseif strcmpi(inps.Results.orient, 'landscape') %-- landscape fill page.
      set(gcf, 'PaperPositionMode', 'manual');
      set(gcf, 'PaperUnits', 'inches');
      set(gcf, 'PaperOrientation', 'landscape');
      set(gcf, 'PaperPosition', [.25 .25 10.5 8]);
   else
      disp(sprintf('--- %s: Invalid orient!', mfilename))
      keyboard
   end


   %--- layout of subpannels
   %
   np = length(pCmd); %number of sub pannels.   
   if np==1
      nant = 1;
      nrow = 3+nant;
      ncol = 1;
      spbox = {[1,(nrow-nant)*ncol],...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==2
      nant = 1;
      nrow = 4+nant;
      ncol = 1;
      spbox = {[1,2],[3,4],...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==3
      nant = 1;
      nrow = 6+nant;
      ncol = 1;
      spbox = {[1,2],[3,4],[5,6],...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==4
      nant = 1;
      nrow = 2+nant;
      ncol = 2;
      spbox = {1,2,3,4,...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==5 || np==6
      nant = 1;
      nrow = 3+nant;
      ncol = 2;
      spbox = {1,2,3,4,5,6,...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==7 || np==8
      nant = 1;
      nrow = 4+nant;
      ncol = 2;
      spbox = {1,2,3,4,5,6,7,8,...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   elseif np==9
      nant = 1;
      nrow = 6+nant;
      ncol = 3;
      spbox = {[1,4],  [2,5 ], [3,6 ],...
               [7,10], [8,11], [9,12],...
               [13,16],[14,17],[15,18],...
               [(nrow-nant)*ncol+1,nrow*ncol]};
   else
   end
   
   %--- 
   %ib = 0;
   axhdl = nan(1,np+1); %the end handle is for annotation axis.
   for ip=1:np

      axhdl(ip) = subplot(nrow,ncol,spbox{ip});
      set(gca,'FontSize',14);

      %---
      %subplot_1_cmds = {{},{},...}
      %subplot_2_cmds = {{},{},...}
      %pCmd = { subplot_1_cmds, subplot_2_cmds }
      %
      spcmd = inps.Results.pCmd{ip};
      for ic = 1:length(spcmd)         
         cmd = spcmd{ic};
         if isempty(cmd); continue; end
         
         cmdStr = func2str(cmd{1});
         
         if strcmpi(cmdStr,'hist')
            histFlag='yes';
          
         end
        
         if strcmpi( cmdStr, 'showNaN')

            odir=cd('~/srb/dev2/mshare/');
            maytNaNadj();
            cd(odir);

         elseif strcmpi( cmdStr, 'showUSCoast')
            if isempty(usLat) || isempty(usLon)
               load conus;
               usLon = uslon;
               usLat = uslat;
               usStateLon = statelon;
               usStateLat = statelat;
               usGtLakeLon = gtlakelon;
               usGtLakeLat = gtlakelat;
            end
            line(usLon,usLat, cmd{2:end})
            line(usStateLon,usStateLat, cmd{2:end})
            line(usGtLakeLon,usGtLakeLat, cmd{2:end})

         elseif strcmpi( cmdStr, 'showWorldCoast')
            if isempty(worldLat)||isempty(worldLon)
               load coast
               worldLon = long;
               worldLat = lat;
            end
            line(worldLon,worldLat,cmd{2:end})            

         elseif strcmpi( cmdStr, 'showUSCounty')
            if isempty(usCntLat)||isempty(usCntLon)||...
               any(cmd{2}(:)~=usCntBBox(:))
               %geoS = shaperead('~/srb/dev2/uscounties/c_01jl13',...
               %                 'UseGeoCoords', true,...
               %                 'Selector', {@(st) (strcmpi(st,'CA')),'STATE'});
               geoS = shaperead('~/srb/dev2/worldmap/uscounties/c_01jl13',...
                                'UseGeoCoords', true,...
                                'BoundingBox', cmd{2}); %[minX,minY;maxX,maxY]
               usCntLat = horzcat(geoS(:).Lat);
               usCntLon = horzcat(geoS(:).Lon);
               usCntBBox = cmd{2};
            end
            line(usCntLon,usCntLat,cmd{3:end})            


         elseif strcmpi( cmdStr, 'setgcaobj')
            h=findobj(gca,cmd{2}{:});
            set(h,cmd{3:end});

         elseif strcmpi( cmdStr, 'setgcfobj')
            h=findobj(gcf,cmd{2}{:});
            set(h,cmd{3:end});

         elseif strcmpi( cmdStr, 'setgca')
            set(gca,cmd{2:end});

         elseif strcmpi( cmdStr, 'setgcf')
            set(gcf,cmd{2:end});

         elseif strcmpi( cmdStr, 'expandbox')
            %opos=get(gca,'outerposition');%[left bottom width height]
            %ipos=get(gca,'position'); %[left bottom width height]
            %ipos(2)=opos(2)+cmd{2};%0.05;
            %ipos(4)=opos(4)-cmd{2};%0.05;
            %set(gca,'position',ipos);
            ipos=get(gca,'position'); %[left bottom width height]
            ipos(3)=ipos(3)+cmd{2}(1);%[width];
            ipos(4)=ipos(4)+cmd{2}(2);%[height];
            set(gca,'position',ipos);
   
         else
             
             cmd{1}(cmd{2:end});
            
         end 
         
      end %for ic = 1:length(spcmd)

   end %ip=1:np
   

   % add Text
   if strcmpi(histFlag,'yes') 
       xlabelStr = inps.Results.labelstr{1};
       ylabelStr = inps.Results.labelstr{2};
       xi=0;
       yi=0;
       dy=0;
       Bias = inps.Results.Statistics{1};
       avg  = inps.Results.Statistics{2};
       RMS  = inps.Results.Statistics{3};
       Std  = inps.Results.Statistics{4};
       Corr = inps.Results.Statistics{5};
       N    = inps.Results.Statistics{6};
       Norig= inps.Results.Statistics{7};
   
   xlim = get(gca,'xLim');
   ylim = get(gca,'yLim');
   xlim(1) = xlim(1)-5;
   xlim(2) = xlim(2)+5;
   set(gca,'xLim',xlim,'yLim',ylim);
%    xBottomTicks = get(gca,'xTick');
 
   if  abs(xlim(1))>=abs(xlim(2))
   xi =xlim(1)+abs(xlim(1))/20.;
   elseif abs(xlim(1))<abs(xlim(2)) 
       xi= xlim(2)/2.5;
   end
   
   yi = ylim(2)*0.95;
   dy = yi/10;
   text(xi,yi,['Corr = ', num2str(Corr,'%4.2f')],...
   'FontName', 'Times New Roman','FontSize', 16,'fontweight','bold' );
%],...%
   text(xi,yi-1*dy,['Bias = ', num2str(Bias,'%4.2f'),'(',num2str(abs(Bias/avg)*100,'%3.1f'),'%)'],...
   'FontName', 'Times New Roman','FontSize', 16,'fontweight','bold' );

   text(xi,yi-2*dy,['RMS  = ', num2str(RMS,'%4.2f'),'(',num2str(abs(RMS/avg)*100,'%3.1f'),'%)'],...
   'FontName', 'Times New Roman','FontSize', 16,'fontweight','bold' );

   text(xi,yi-3*dy,['  N  = ', num2str(N,'%d')],...
   'FontName', 'Times New Roman','FontSize', 16,'fontweight','bold' )

   xlabel(xlabelStr,'FontName',...
    'Times New Roman','fontsize',16,'fontweight','bold');
   ylabel(ylabelStr,'FontName',...
    'Times New Roman','fontsize',16,'fontweight','bold');
   
   end %end histFlag
   %--- Anotation
   %
   axhdl(end) = subplot(nrow,ncol, spbox{end});
   axis off;
   opos=get(gca,'outerposition');
   %ipos=get(gca,'position');
   %ipos(1)=opos(1);
   %ipos(3)=opos(3);
   opos(opos<0)=0;
   opos(opos>1)=1;
   set(gca,'position',opos);
   
   [st,cwk] = dbstack('-completenames'); %get current .m filename and funciton name.
   [codePath,codeFile,codeExt] = fileparts(st(2).file);
   funcName = st(2).name;
   [figPath,figFile,figExt] = fileparts(inps.Results.figName);

   anotStr={[' '],[' '],inps.Results.anotStr{:},...
            ['Plotting code: ',texlabel([codeFile,codeExt,'/',funcName,'(). '],'literal'),...
             'Path: ', texlabel([codePath,'/. '],'literal'),...
             'Plotting date: ',date,'. ',...
             'Figure file: ', texlabel([figFile,figExt],'literal'),...
            ]};

   anno= annotation('textbox',get(gca,'Position'),'String',...
                    anotStr, 'LineStyle','none');%,'FontSize',11);


   %--- print fig file
   if strcmpi(inps.Results.plotFlag,'yes')
      
      print('-depsc2',[inps.Results.figName, '.eps']);
%       delete(anno);
%       print('-depsc2',[inps.Results.figName, '_nocapt.eps']);
   end

   varargout{1} = axhdl;

end




