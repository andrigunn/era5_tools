
%    reference_period = [datetime(2024,05,01),...
%       datetime(2024,06,01),...
%       datetime(2024,07,01),...
%       datetime(2024,08,01)]


for i = 1:4
reference_period = [datetime(2024,05,01),...
    datetime(2024,06,01),...
    datetime(2024,07,01),...
    datetime(2024,08,01)]

var = 'sst'
figure,

tiledlayout(2,4,"TileSpacing","tight")
x = 36;
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


hold on
ix = find(nc.Time==reference_period(i))

pcolor(double(Lon),double(Lat),nc.([char(string(var)),'_anomalies'])(:,:,ix))
shading interp % eliminates black lines between grid cells
hold on
borders('countries','color',rgb('white'))

caxis([-2 2])

xlim([lonlimit])
ylim([latlimit])

cmocean('balance','pivot',0) % cold-to-hot colormap

set(gca,'Color','k')
set(0, 'DefaultAxesColor', 'white')

colorbarHandle = colorbar;

colorbarHandle.Label.String = 'SST anomalie (°C)';  % Add label to the colorbar

% Customize the colorbar label font color (optional)
colorbarHandle.Label.Color = 'w';  % Set colorbar label color to white
% Customize the font size (optional)
colorbarHandle.Label.FontSize = 15;
set(colorbarHandle, 'Color', 'w');  % Set colorbar text color to white

% Change the background color of the figure to black
set(gcf, 'Color', 'k');  % 'gcf' is the current figure handle
set(gca, 'Color', 'k');  % 'gca' is the current axes handle
set(gca, 'XColor', 'w', 'YColor', 'w');  % Set x and y axis color to white

text(0.99,1.01,['Frávik sjávarhita - Viðmið: 1990-2020'],...
    'Units','normalized','HorizontalAlignment','right',...
    'VerticalAlignment','bottom','FontSize',16,'FontWeight','bold',...
    'Interpreter','none','Color','w');

title([datestr(nc.Time(ix),'mmm yyyy')],'Color','w',...
    'FontSize',28)


% Optionally, change the grid lines to white if grid is enabled
grid on;
set(gca, 'GridColor', 'w');
img_dir = '/Users/andrigun/Dropbox/tmp/'
img_name = ['era5-single-levels-monthly-anomalies-',var,'_',[datestr(nc.Time(ix),'mmm_yyyy')]]
exportgraphics(gcf,[img_dir,img_name,'.jpg'], 'BackgroundColor', "k");

end
%title(['Frávik sjávarhita - Viðmið: 1990-2020'],'color','w','FontSize', 20)
%        exportgraphics(gcf,[img_dir,img_name,'.pdf'], 'BackgroundColor', "k");
