
%% sst er lesið inn í plt_anomalies_single_level_mm
% Qtbl er úr analyse_river fyrir tungnaá. Eða hvaða vatnsfall sem er 
tblM = retime(Qtbl,'monthly','mean')
%%
figure
tiledlayout(1,4,"TileSpacing","tight")

M = [9]

for i = 1%:4
%
m = M(i);
    ix = find(tblM.Time.Month==m)
%
% Find the indices of matching dates in vector1 that exist in vector2
[isMatch, idxVector1] = ismember(tblM.Time(ix), nc.Time);

% Display matching indices in vector1 and corresponding indices in vector2
matchingIndicesVector1 = find(isMatch);  % Indices in vector1
matchingIndicesVector2 = idxVector1(isMatch) % Corresponding indices in vector2

%
sst = nc.sst(:,:,matchingIndicesVector2);
mean_sst = mean(sst,3,'omitmissing');
nc.Time(matchingIndicesVector2)
%
[r,p]=corr3(sst,tblM.data(ix));
%
x = 18;
y = 52;

set(0,'defaultfigurepaperunits','centimeters');
set(0,'DefaultAxesFontSize',15)
set(0,'defaultfigurecolor','w');
set(0,'defaultfigureinverthardcopy','off');
set(0,'defaultfigurepaperorientation','landscape');
set(0,'defaultfigurepapersize',[y x]);
set(0,'defaultfigurepaperposition',[.25 .25 [y x]-0.5]);
set(0,'DefaultTextInterpreter','none');
set(0, 'DefaultFigureUnits', 'centimeters');
set(0, 'DefaultFigurePosition', [.25 .25 [y x]-0.5]);

latlimit = [40 75];
lonlimit = [-50 30];

nexttile, hold on

pcolor(double(Lon),double(Lat),r)
caxis([-1 1])
cmocean balance
%colorbarHandle = colorbar;

shading flat
borders('countries','color',rgb('black'))
hold on
stipple(double(Lon),double(Lat),(p<0.05),'markersize',8,'density',500) % regions of significance

    xlim([lonlimit])
    ylim([latlimit])

    cmocean('balance','pivot',0) % cold-to-hot colormap

    set(gca,'Color','k')
    set(0, 'DefaultAxesColor', 'white')

    % Change the background color of the figure to black
    set(gcf, 'Color', 'k');  % 'gcf' is the current figure handle
    set(gca, 'Color', 'k');  % 'gca' is the current axes handle
    set(gca, 'XColor', 'w', 'YColor', 'w');  % Set x and y axis color to white

%
    % Add a colorbar
    if m == 12
        colorbarHandle = colorbar;
        colorbarHandle.Label.String = 'Fylgnistuðull (-)';  % Add label to the colorbar
        colorbarHandle.Label.Color = 'w';  % Set colorbar label color to white
        % Customize the font size (optional)
        colorbarHandle.Label.FontSize = 15;
        set(colorbarHandle, 'Color', 'w');  
        ylabel(colorbarHandle,'correlation coefficient R')

    else
    end
    % Change the background color of the figure to black
    set(gcf, 'Color', 'k');  % 'gcf' is the current figure handle
    set(gca, 'Color', 'k');  % 'gca' is the current axes handle
    set(gca, 'XColor', 'w', 'YColor', 'w');  % Set x and y axis color to white

    title([datestr(nc.Time(matchingIndicesVector2(1)),'mmm')],'Color','w')

        % Optionally, change the grid lines to white if grid is enabled
    grid on;
    set(gca, 'GridColor', 'w');

end
        sgtitle(['Fylgni sjávarhita og rennslis í Tungnaá'],'color','w','FontSize', 20)


img_dir = '/Users/andrigun/Library/CloudStorage/OneDrive-Landsvirkjun/Verkefni - [T] Vatnafarsrannsóknir/Horfur vatnafars/Hofur og staða vatnafars/2024-09-11/'
img_name = ['sst_vs_rennsli_tungnaá']
%exportgraphics(gcf,[img_dir,img_name,'.jpg'], 'BackgroundColor', "k");
%exportgraphics(gcf,[img_dir,img_name,'.pdf'], 'BackgroundColor', "k");
