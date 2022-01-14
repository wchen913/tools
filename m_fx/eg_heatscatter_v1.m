function main()
addpath('/data/srb1/wchen/tools/m_fx/','-end')
%{
x=random('Normal',282,14,5000*4,1);
y=random('Normal',278,12,5000*4,1);
heatscatters(x,y)
%}
pth       = '/data/srb2/wchen/LST/SKT/';
dynt      ='Day';
optOut    = 'yes'; 
StName    = 'ARMsgpC1'
lev       = num2str(10);
Sat       = 'GOES_E'
version   = 'UMD_RTTOV'%'UMD_MORTRAN';
time_step = 'inst_hourly';

xlim     = [250 340];
ylim     = xlim;
nxbin    = 20;
nybin    = nxbin;
%+++++
%situ
%+++++
StLat       = [36.605];
StLon       = [-97.485]	;
nSt         = num2str(length(StLat)) 

switch dynt
case {'day','daytime','Day','DAY','Daytime','DAYTIME'};ncvar='lst_dy';
case {'night','nighttime','Night','NIGHT','Nighttime','NIGHTTIME'};ncvar='lst_nt';
case {'Allday','ALLDAY','allday'};ncvar = 'LST';
end
stfname = ['LST_',StName,'_',nSt,'st_',lev,'m_',time_step,'_2004_2009.nc']
y=ncread([pth,stfname],ncvar);
y=double(y(:));
y(y<0)=NaN;
disp([min(y),max(y)])
%++++++++++
%Estimation
%++++++++++
 estfname = ['LST_GOES_E_',version,'_4_',StName,'_',nSt,'st_',time_step,'_2004_2009.nc']
 x = ncread([pth,estfname],'lst');
 x=double(x(:));
 x(x<0)=NaN;
 disp([min(x),max(x)])
 %++++++++++++++++++
 x(isnan(y))=NaN;
 y(isnan(x))=NaN;
%+++++++++++
% Statistics
%+++++++++++
 [Bias,avg,RMSE,Std,stdbfr,Corr,npts,N,outline]=CalculateStatistics_v4(x,y,1,optOut);  
 statistics =  {sprintf('Corr: %.2f', Corr),sprintf('Bias: %.2f', Bias), ...
 sprintf('Std: %.2f', Std),sprintf('RMSE: %.2f', RMSE),...
 sprintf('N: %d', N)};  
 if strcmpi(optOut,'yes') 
                x(outline)=NaN;
                y(outline)=NaN;
                clear outline
 end 
 inds = find(~isnan(x));
 xx   = x(inds);
 yy   = y(inds);
 disp([length(xx),length(xx)])
 disp([min(x),max(x);min(y),max(y)])
%++++++++++
% Plotting
%++++++++++ 
FigName =  ['LST_',Sat,'_',version,'_vs_',StName,'_',nSt,'st_',time_step,'_2004_2009']
tistrs  = {'Situ LST','Estimated LST',''} 
 
heatscatters(xx,yy,'60',tistrs,statistics)
 

line(xlim,ylim,'LineStyle','--','color', 'k','linewidth',2.5)

set(gca,'xlim',xlim,'xtick',xlim(1):nxbin:xlim(2),'ylim',ylim,'ytick',ylim(1):nybin:ylim(2),...
'linewidth',2.125,'FontSize', 12.5,'fontweight','bold');
  
figid = annotation('textbox', [0.58 0.16 0.1 0.1],...
 'String', {insertAfter(upper(StName),'ARM','/'),dynt},...
  'EdgeColor', 'none');
set(figid, 'FontSize', 12.5,'fontweight','bold')
fig=gcf;
print(fig,'-djpeg','-r300',['heatscatter_',FigName])
print('-depsc2','-r300',['heatscatter_',FigName])
% print('-dpng','-r300',['heatscatter_',FigName])
end

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
		str=stats
	 end
    [values, centers] = hist3([X Y], [numbins numbins]);

    centers_X = centers{1,1};
    centers_Y = centers{1,2};

    binsize_X = abs(centers_X(2) - centers_X(1)) / 2;
    binsize_Y = abs(centers_Y(2) - centers_Y(1)) / 2;
    bins_X = zeros(numbins, 2);
    bins_Y = zeros(numbins, 2);

    for i = 1:numbins
        bins_X(i, 1) = centers_X(i) - binsize_X;
        bins_X(i, 2) = centers_X(i) + binsize_X;
        bins_Y(i, 1) = centers_Y(i) - binsize_Y;
        bins_Y(i, 2) = centers_Y(i) + binsize_Y;
    end

    scatter_COL = zeros(length(X), 1);

    onepercent = round(length(X) / 100);
    
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

        scatter_COL(i) = values(id_X, id_Y);
    
    end
    
    fprintf(' Done!\n');
    
    fprintf('Plotting...');
    
    f = figure();
    colormap(jet)
    
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
        txt=annotation('textbox', [0.14 0.80 0.1 0.1], 'String', str, 'EdgeColor', 'none');
        set(txt, 'FontSize', 12.5,'fontweight','bold')
    end
    
     
        xlabel(tistrs(1));
     
     
        ylabel(tistrs(2));
    
     
        title(tistrs(3));
    
    
  

    
%     [p,n,r] = fileparts(outname);
%     if (isempty(r))
%         r = '.pdf';
%     end
%     outname = strcat(p,n,r);
%     outfile = fullfile(outpath, outname);
%     saveas(f, outfile);
%     fprintf(' Done!\n');
    
end
 %statistics =  cellstr(num2str([Bias;avg;RMSE;Std;Corr;N]))
 %axis([xlim,ylim],'linewidth',2.5,'FontSize', 16,'fontweight','bold')
