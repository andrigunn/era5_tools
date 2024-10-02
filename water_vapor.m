

% Make stromtrack data
if ismac
    folder = '/Volumes/data/reanalysis-era5-single-levels-monthly-means/'
else isunix
    folder = ''
end
%%
nino_mm = make_nino34;
%%
file = [folder,'reanalysis-era5-single-levels-monthly-means-vertical_integral_of_eastward_water_vapour_flux.nc']
eastward_water_vapour_flux = ncstruct(file)
%%
file = [folder,'reanalysis-era5-single-levels-monthly-means-vertical_integral_of_northward_water_vapour_flux.nc']
northward_water_vapour_flux = ncstruct(file)
%%
file = [folder,'reanalysis-era5-single-levels-monthly-means-mean_sea_level_pressure.nc']
mean_sea_level_pressure = ncstruct(file)
%%
ERA5.brautir =sqrt(northward_water_vapour_flux.viwvn.^2 ...
    +eastward_water_vapour_flux.viwve.^2);
%%
lat = eastward_water_vapour_flux.latitude;
lon = eastward_water_vapour_flux.longitude;
[Lat,Lon,T] = recenter(lat,lon,ERA5.brautir);
%%
[Lat2,Lon2,mslp] = recenter(lat,lon,mean_sea_level_pressure.msl);
%%
k = 920;
figure, hold on
data = flipud(rot90(T(:,:,k)));
data(data<100) = NaN;
h = pcolor(Lon,Lat,data);
shading flat
colorbar
colormap("jet")

cRange = caxis; % save the current color range
hold on;
contour(Lon,Lat,flipud(rot90(nc.msl_anomalies(:,:,k))),10,'--k')
%caxis(cRange); 
clim([100 400])
%
title(datestr(datetime(num2str(double(mean_sea_level_pressure.date(k))), 'InputFormat', 'yyyyMMdd')))

%
gif('myfile7.gif')
%
for k = 920:1016
    clf
    data = flipud(rot90(T(:,:,k)));
    data(data<100) = NaN;
    h=pcolor(Lon,Lat,data);
    shading flat
    colorbar
    colormap("jet")
    
    cRange = caxis; % save the current color range
    hold on;
    contour(Lon,Lat,flipud(rot90(mslp(:,:,k))),10,'--k')
    %caxis(cRange); 
    clim([100 400])
    title(datestr(datetime(num2str(double(mean_sea_level_pressure.date(k))), 'InputFormat', 'yyyyMMdd')))
    borders('countries','color',rgb('dark gray'))
    gif
end


%%
k = 920;

fig=figure, hold on

%set(fig, 'Color', 'k');
ax = gca;
set(ax, 'Color', 'k');
set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
ax.XLabel.Color = 'k';
ax.YLabel.Color = 'k';
ax.ZLabel.Color = 'k';
ax.Title.Color = 'k';

data = flipud(rot90(T(:,:,k)));
data(data<100) = NaN;
h=pcolor(Lon,Lat,data);
colormap('turbo')
cb1 = colorbar('southoutside');
xlabel(cb1,'Rakaflæði (vertical integral of water vapour flux) (kg/m2)')
shading flat

cb2 = newcolorbar
contour(Lon,Lat,nc.msl_anomalies(:,:,k),25,'LineWidth',1.3)
%colormap('jet')
cmocean('balance','pivot',0)
cb2 = colorbar
xlabel(cb2,'Frávik loftþrýstings (Pa)')

set(cb1, 'Color', 'w');
cb1.Label.Color = 'w';
set(cb2, 'Color', 'w');
cb2.Label.Color = 'w';

borders('countries','color',rgb('dark gray'))
borders('iceland','facecolor','white')

title(datestr(datetime(num2str(...
    double(mean_sea_level_pressure.date(k))),...
    'InputFormat', 'yyyyMMdd')),'Color','w')

gif('myfile8.gif')

for k = 920:930
    clf
    set(fig, 'Color', 'k');
    
    ax = gca;
    set(ax, 'Color', 'k');
    set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
    set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
    ax.XLabel.Color = 'k';
    ax.YLabel.Color = 'k';
    ax.ZLabel.Color = 'k';
    ax.Title.Color = 'k';

    data = flipud(rot90(T(:,:,k)));
    data(data<100) = NaN;
    h=pcolor(Lon,Lat,data);
    colormap('turbo')
    cb1 = colorbar('southoutside');
    xlabel(cb1,'Rakaflæði (vertical integral of water vapour flux) (kg/m2)')
    shading flat

    cb2 = newcolorbar
    contour(Lon,Lat,nc.msl_anomalies(:,:,k),25,'LineWidth',1.3)
    %colormap('jet')
    cmocean('balance','pivot',0)
    cb2 = colorbar
    xlabel(cb2,'Frávik loftþrýstings (Pa)')
    
    set(cb1, 'Color', 'w');
    cb1.Label.Color = 'w';
    set(cb2, 'Color', 'w');
    cb2.Label.Color = 'w';

    borders('countries','color',rgb('dark gray'))
    borders('iceland','facecolor','white')
    
    title(datestr(datetime(num2str(...
        double(mean_sea_level_pressure.date(k))),...
        'InputFormat', 'yyyyMMdd')),'Color','w')

      gif
end
% Set the font color of the colorbar labels

%contourcmap(cmocean('balance'))
