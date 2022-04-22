%addpath('/data/srb1/wchen/tools/m_fx/','-end')
addpath('/Users/wenchen/fx/m_fx//','-end')

pth       = './';
StOrg     = 'BSRN_CHN_site';
EstOrg    = 'Orgs';%'LIS3','UMD','MERRA2','ERA5','CFSR';
EstOrgNames = {'LIS3','UMD','ERA5','CFSR','MERRA2'};

nStd      = 0;
FigName   = ['./figs/heatscatters_ssda_',EstOrg,'_vs_',StOrg,'_all_rm_cld'];         
if nStd == 0
    optOut = 'no';
else
    optOut = 'yes';   
end
xlim	 = [0 500];ylim     = xlim;
nxbin	 = 100;nybin    = nxbin;
%++++++++++
%Estimation
%++++++++++
stid = importfile("./BSRNused.csv", [2, Inf]);
nSt  = length(stid);
ist0 = 21;
istn = 21;

% ssda_SURFRAD_7st_daily_20131001_20150831.nc
%ssda_UMD_and_LIS3INSTAVGS_4_SURFRAD_7st_daily_20131001_20150831.nc
 estfname = [pth,'ssda_',EstOrg,'_4_BSRN_24st_daily_20131001_20150831_ERA5redownloaded.nc'];
 %ncdisp(estfname)
 estdata  = ncread(estfname,'ssda');
 estdata(estdata<0)=NaN;
%  whos estdata
 %estdata(1,1,1:10)


 fid = fopen('MissingCloudsYMD.dat','r');
 indmiss = fread(fid,[179 1],'double');
 fclose(fid);
 estdata(:,:,indmiss)=NaN;
 nt  = length(estdata);
 disp(nt)

 stdata = nan(nSt,nt);
 for ist  = 1:nSt
     stname  = strtrim(stid{ist});
     stfname = [pth,'ssda_BSRN_',char(lower(stname)),'_daily_20131001_20150831.dat']; 
     disp(stfname)
     fid     = fopen(stfname,'r');
     stdata(ist,:)=fread(fid,nt,'float32');
 end
  stdata(stdata<0)=NaN;
  
%  whos stdata
 xtmp = stdata(ist0:istn,:);
 x = xtmp(:);
%  disp([min(x),max(x)])
    
 %------compare with UMD-----
 for iorg = 1:5
 ytmp = estdata(iorg,ist0:istn,:);
 y    = ytmp(:);
%  disp([min(y),max(y)])
 %++++++++++++++++++
 x(isnan(y))=NaN;
 y(isnan(x))=NaN;
%+++++++++++
% Statistics
%+++++++++++
 [Bias,avg,RMSE,Std,stdbfr,Corr,npts,N,outline]=CalculateStatistics_v5(x,y,1,nStd,optOut);  

 statistics =  {EstOrgNames{iorg},sprintf('Corr: %.2f', Corr),...
                [sprintf('Bias: %.1f', Bias), '(',num2str(abs(Bias/avg)*100,'%.1f'),'%)'],...
                [sprintf('Std: %.1f', Std),'(',num2str(abs(Std/avg)*100,'%.1f'),'%)'],...
                 [sprintf('RMSE: %.1f', RMSE),'(',num2str(abs(RMSE/avg)*100,'%.1f'),'%)'],...
                 sprintf('N: %d', N)};
%  disp(statistics)


 Corrs(iorg) = Corr;
 Biass(iorg) = Bias;
 Biasp(iorg) = abs(Bias/avg)*100;
 Stds(iorg)  = Std;
 Stdp(iorg)  = abs(Std/avg)*100;
 RMSEs(iorg) = RMSE;
 RMSEp(iorg) = abs(RMSE/avg)*100;
 Ns(iorg)    = N;
 
 if strcmpi(optOut,'yes') 
                x(outline)=NaN;
                y(outline)=NaN;
                clear outline
 end 
 inds = find(~isnan(x));
 xx   = x(inds);
 yy   = y(inds);
%  disp('-----min/max x/y')
%  disp([min(xx),max(xx);min(yy),max(yy)])
 %disp([length(xx),length(yy)])

%++++++++++
% Plotting
%++++++++++ 

tistrs  = {'Observed SW{\downarrow} (W m^{-2})','Estimated SW{\downarrow} (W m^{-2})',''};

figure()
denscatplot(double(xx),double(yy),'circle',[],[],[],[],8); 
% heatscatters(xx,yy,'100',tistrs,statistics,'100')
lmd=fitlm(xx,yy);
rc = lmd.Rsquared.Adjusted;
z  = rc*(xx-mean(xx))+mean(yy);
line(xx,z,'color', 'red','linewidth',2.5)
line(xlim,ylim,'LineStyle','--','color', 'k','linewidth',2.5)
set(gca,'xlim',xlim,'xtick',xlim(1):nxbin:xlim(2),'ylim',ylim,'ytick',ylim(1):nybin:ylim(2),...
'linewidth',2.125,'FontSize', 22,'fontweight','bold','FontName', 'Times');
PP=get(gca,'Position');
set(gca,'Position',[PP(1)+0.01 PP(2)+0.035 PP(3)+0.05 PP(4)]);
xlabel(tistrs(1),'Position',[250,-35,-1]);        
ylabel(tistrs(2)); 
colorbar

cap1=annotation('textbox', [0.25 0.8 0.1 0.1],...
 'String',[EstOrgNames{iorg},' .vs. BSRN/CHN'],...
  'EdgeColor', 'none', 'FontSize', 22,'fontweight','bold','FontName', 'Times');  
%
% if iorg==1 || iorg==3
%   cap1=annotation('textbox', [0.35 0.16 0.1 0.1],...
%  'String',[EstOrgNames{iorg},' .vs. BSRN/CHN'],...
%   'EdgeColor', 'none', 'FontSize', 22,'fontweight','bold','FontName', 'Times');
% else 
% cap1=annotation('textbox', [0.35 0.8 0.1 0.1],...
%  'String',[EstOrgNames{iorg},' .vs. BSRN/CHN'],...
%   'EdgeColor', 'none', 'FontSize', 22,'fontweight','bold','FontName', 'Times');  
% end
%}
% cap2=annotation('textbox', [0.175 0.77 0.1 0.1],...
%  'String','(a)',...
%   'EdgeColor', 'none', 'FontSize', 25,'fontweight','bold','FontName', 'Times');
ax1=gca;
% set(gcf,'PaperUnits', 'inches');
% set(gcf,'PaperSize', [2 1]);
% print(gcf,'-djpeg','-r300',[FigName,'_',EstOrgNames{iorg}])


% print(fig,'-depsc2','-r300',['./figs/heatscatters_',FigName])
% print(fig,'-dpng','-r300',['heatscatter_',FigName])
                
 end
 
 T = table(Corrs',Biass',Biasp',Stds',Stdp',RMSEs',RMSEp',Ns',...
     'VariableNames',{'Corr' 'Bias' 'BiasP' 'Std' 'StdP' 'RMSE' 'RMSEp' 'N'},...
     'RowNames',EstOrgNames');
 disp(T)
 writetable(T,[FigName,'_Stats_ERA5redownloaded.txt'],'Delimiter','tab')  
%
function outfile = heatscatters(X, Y, numbins, tistrs,stats,markersize, marker, plot_colorbar, plot_lsf )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% heatscatter(X, Y, outpath, outname, numbins, markersize, marker, plot_colorbar, plot_lsf, xlab, ylab, title)
% mandatory:
%            X                  [x,1] array containing variable X
%            Y                  [y,1] array containing variable Y
%            outpath            path where the output-file should be saved.
%                                leave blank for current working directory
%            outname            name of the output-file. if outname contains
%                                filetype (e.g. png), this type will be used.
%                                Otherwise, a pdf-file will be generated
% optional:
%            numbins            [double], default 50
%                                number if bins used for the
%                                heat3-calculation, thus the coloring
%            markersize         [double], default 10
%                                size of the marker used in the scatter-plot
%            marker             [char], default 'o'
%                                type of the marker used in the scatter-plot
%            plot_colorbar      [double], boolean 0/1, default 1
%                                set whether the colorbar should be plotted
%                                or not
%            plot_lsf           [double], boolean 0/1, default 1
%                                set whether the least-square-fit line
%                                should be plotted or not (together with
%                                the correlation/p-value of the data
%            xlab               [char], default ''
%                                lable for the x-axis
%            ylab               [char], default ''
%                                lable for the y-axis
%            title              [char], default ''
%                                title of the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%% mandatory
    if ~exist('X','var') || isempty(X)
        error('Param X is mandatory! --> EXIT!');
    end
    if ~exist('Y','var') || isempty(Y)
        error('Param Y is mandatory! --> EXIT!');
    end
%     if ~exist('outpath','var')
%         error('Param outpath is mandatory! --> EXIT!');
%     end
%     if ~exist('outname','var') || isempty(outname)
%         error('Param outname is mandatory! --> EXIT!');
%     end
    
    %%%% optional
    if ~exist('numbins','var') || isempty(numbins)
        numbins = 20;
    else
        % force number, not char input
        numbins = str2double(numbins);
    end
    if ~exist('markersize','var') || isempty(markersize)
        markersize = 50;
    else
        % force number, not char input
        markersize = str2double(markersize);
    end
    if ~exist('marker','var') || isempty(marker)
        marker = '.';
    end
    if ~exist('plot_colorbar','var') || isempty(plot_colorbar)
        plot_colorbar = 1;
    end
    if ~exist('plot_lsf','var') || isempty(plot_lsf)
        plot_lsf = 1;
    end
    if ~exist('tistrs','var') || isempty(tistrs)
        tistrs ={'','',''} ;
    end
    if ~exist('stats','var') || isempty(stats)      
		[r,p] = corr(X, Y);
		str = {sprintf('corr: %.3f', r), sprintf('pval: %d', p)};
		else
		str=stats;
	 end
    [values, centers] = hist3([X Y], [numbins numbins]);
%     disp([min(values(:)),max(values(:))])

    centers_X = centers{1,1};
    centers_Y = centers{1,2};
%     disp([min(centers_X),max(centers_X)])
%     disp([min(centers_Y),max(centers_Y)])

    
    binsize_X = abs(centers_X(2) - centers_X(1)) / 2 ;
    binsize_Y = abs(centers_Y(2) - centers_Y(1)) / 2 ;
    bins_X = zeros(numbins, 2);
    bins_Y = zeros(numbins, 2);

    for i = 1:numbins
        bins_X(i, 1) = centers_X(i) - binsize_X;
        bins_X(i, 2) = centers_X(i) + binsize_X;
        bins_Y(i, 1) = centers_Y(i) - binsize_Y;
        bins_Y(i, 2) = centers_Y(i) + binsize_Y;
    end
%     disp([bins_X;bins_Y])
    scatter_COL = zeros(length(X), 1);

    onepercent = round(length(X) / 100.);
    
    fprintf('Generating colormap...\n');
    
    for i = 1:length(X)

        if (mod(i,onepercent) == 0)
            fprintf('.');
        end            

        last_lower_X = NaN;
        last_higher_X = NaN;
        id_X = NaN;

        c_X = X(i);
        last_lower_X = find(c_X >= bins_X(:,1));
        if (~isempty(last_lower_X))
            last_lower_X = last_lower_X(end);
        else
            last_higher_X = find(c_X <= bins_X(:,2));
            if (~isempty(last_higher_X))
                last_higher_X = last_higher_X(1);
            end
        end
        if (~isnan(last_lower_X))
            id_X = last_lower_X;
        else
            if (~isnan(last_higher_X))
                id_X = last_higher_X;
            end
        end

        last_lower_Y = NaN;
        last_higher_Y = NaN;
        id_Y = NaN;

        c_Y = Y(i);
        last_lower_Y = find(c_Y >= bins_Y(:,1));
        if (~isempty(last_lower_Y))
            last_lower_Y = last_lower_Y(end);
        else
            last_higher_Y = find(c_Y <= bins_Y(:,2));
            if (~isempty(last_higher_Y))
                last_higher_Y = last_higher_Y(1);
            end
        end
        if (~isnan(last_lower_Y))
            id_Y = last_lower_Y;
        else
            if (~isnan(last_higher_Y))
                id_Y = last_higher_Y;
            end
        end
%         disp([num2str(id_X),' ',num2str(id_Y),' ',num2str(values(id_X, id_Y))])
        scatter_COL(i) = values(id_X, id_Y);
        
    end
    disp([min(scatter_COL),max(scatter_COL)])
    fprintf(' Done!\n');
    
    fprintf('Plotting...');
    
    f = figure();
    %colormap(jet)
     load BlAqGrYeOrReVi200.rgb %BlGrYeOrReVi200.rgb
     colormap(BlAqGrYeOrReVi200/255.) %(BlGrYeOrReVi200/255.)
    
    scatter(X, Y, markersize, scatter_COL, marker);
	ax = gca;
	box(ax,'on')
    
    if (plot_colorbar)
        colorbar;      
    end
    
    if (plot_lsf)
        %[r,p] = corr(X, Y);
        %str = {sprintf('corr: %.3f', r), sprintf('pval: %d', p)};
        l = lsline;
        set(l, 'Color', 'r','LineStyle','-','linewidth',2.5);
        %txt=annotation('textbox', [0.14 0.80 0.1 0.1], 'String', str, 'EdgeColor', 'none');
        %set(txt, 'FontSize', 12.5,'fontweight','bold')
    end
         
        xlabel(tistrs(1));        
        ylabel(tistrs(2));     
        title(tistrs(3));
  
end
function stid = importfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  BSRNUSED = IMPORTFILE(FILENAME) reads data from text file FILENAME
%  for the default selection.  Returns the data as a table.
%
%  BSRNUSED = IMPORTFILE(FILE, DATALINES) reads data for the specified
%  row interval(s) of text file FILENAME. Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%
%  Example:
%  BSRNused = importfile("/Users/wenchen/Documents/Work/Modis/LIS/BSRNused.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 20-Jan-2021 17:50:14

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Stationfullname", "Abbreviation", "Location", "Latitude", "Longitude", "Elevation", "Firstdatasetinarchive", "UpwardfluxesinLR", "Surfacetype", "Topographytype", "RuralUrbanII"];
opts.VariableTypes = ["string", "string", "string", "double", "double", "double", "datetime", "double", "categorical", "categorical", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Stationfullname", "Abbreviation", "Location"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Stationfullname", "Abbreviation", "Location", "Surfacetype", "Topographytype", "RuralUrbanII"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Firstdatasetinarchive", "InputFormat", "MM/dd/yy");
opts = setvaropts(opts, "UpwardfluxesinLR", "TrimNonNumeric", true);
opts = setvaropts(opts, "UpwardfluxesinLR", "ThousandsSeparator", ",");

% Import the data
StInfo = readtable(filename, opts);
stid = table2cell(StInfo(:,2));
StLat = table2array(StInfo(:,4));
StLon = table2array(StInfo(:,5));


end
%}
 %statistics =  cellstr(num2str([Bias;avg;RMSE;Std;Corr;N]))
 %axis([xlim,ylim],'linewidth',2.5,'FontSize', 16,'fontweight','bold')
 %{
x=random('Normal',282,14,5000*4,1);
y=random('Normal',278,12,5000*4,1);
heatscatters(x,y)
%}
