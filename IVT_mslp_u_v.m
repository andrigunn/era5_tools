%2m_temperature.nc
%sea_level_pressure.nc
%sea_surface_temperature.nc
%total_cloud_cover.nc
%total_column_water_vapour.nc
%total_precipitation.nc
baseline_period = [datetime(1990,09,30),datetime(2020,10,01)];

if ismac
    cd /Users/andrigun/Desktop/
    img_dir = '/Users/andrigun/Library/CloudStorage/OneDrive-Landsvirkjun/Verkefni - [T] Vatnafarsrannsóknir/Horfur vatnafars/Hofur og staða vatnafars/2024-09-11/'
    addpath /Users/andrigun/Dropbox/04-Repos/cdt/
    addpath /Users/andrigun/Dropbox/04-Repos/cdt/cdt_data/

elseif isunix
    addpath /data/git/cdt
    addpath /data/git/cdt/cdt_data
    cd /data/reanalysis-era5-single-levels-monthly-means/
    img_dir = '/data/tmp/'

end

d = dir('reanalysis-era5-*-monthly-means*.nc')
%%

for k = 1:length(d)

    if contains(d(k).name,'northward_water_vapour_flux')
        continue
    else
    end

    filename = [d(k).folder,filesep,d(k).name];

    if contains(d(k).name,'u_component_of_wind')
        var = 'u';
    elseif contains(d(k).name,'v_component_of_wind')
        var = 'v';
    elseif contains(d(k).name,'eastward_water_vapour_flux')
        var = 'wvf';
    elseif contains(d(k).name,'sea_level_pressure')
        var = 'msl';
    else
    end
    disp(var)

    if contains(d(k).name,'eastward_water_vapour_flux') % Flux case
        % make flux from north and east
        filename = [d(1).folder,filesep,d(4).name];
        nc = ncstruct(filename);

        filename = [d(k).folder,filesep,d(5).name];
        nc2 = ncstruct(filename);

        nc.(string(var)) = sqrt(nc.viwve.^2 ...
            +nc2.viwvn.^2);
        nc.viwvn = nc2.viwvn;

        nc.(string(var)) = flipud(rot90(nc.(string(var))));

    else
        nc = ncstruct(filename);
        % Prep stack
        nc.(string(var)) = flipud(rot90(nc.(string(var))));

        z = size(size(nc.(var)));
        if z(2) == 3

        else
            nc.(var) = squeeze(nc.(var));
        end

    end

    switch var
        case 'tp' % Breytum tp út m/da í mm/month
            nc.(string(var)) = nc.(string(var))*1000*30;
        otherwise
    end

    dateString = num2str([nc.date]);  % Convert number to string
    nc.Time = datetime(dateString, 'InputFormat', 'yyyyMMdd');

    % Make MM anomalies

    sz = size(nc.(string(var)));

    % Create an empty array of the same size
    data_ano = nan(sz);

    for i = 1:12
        %Filter years to use
        ix = find(...
            (nc.Time.Year>=baseline_period.Year(1))&...
            (nc.Time.Year<=baseline_period.Year(2))&...
            (nc.Time.Month==i));

        mmean = mean(nc.(string(var))(:,:,ix),3,'omitmissing'); % mean for the period, month

        jx = find(...
            (nc.Time.Month==i));

        nc.Time(jx);
        nc.Time(ix)

        data_ano(:,:,jx) = nc.(string(var))(:,:,jx)-mmean;

    end

    nc.([char(string(var)),'_anomalies']) = data_ano;

    nc.basePeriod = baseline_period;

    [Lon,Lat] = meshgrid(nc.longitude,nc.latitude);

    [Lat,Lon,nc.([char(string(var)),'_anomalies']),nc.([char(string(var))])] =...
        recenter(Lat,Lon,nc.([char(string(var)),'_anomalies']) ,nc.([char(string(var))]));

    N.(string(var)) = nc;

end

%%
% N is what we use

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

hy = 2023
reference_period = [datetime(hy,09,01),...
    datetime(hy,10,01),...
    datetime(hy,11,01),...
    datetime(hy,12,01),...
    datetime(hy+1,01,01),...
    datetime(hy+1,02,01),...
    datetime(hy+1,03,01),...
    datetime(hy+1,04,01),...
    datetime(hy+1,05,01),...
    datetime(hy+1,06,01),...
    datetime(hy+1,07,01),...
    datetime(hy+1,08,01),...
    ]

for i = 1:12
    fig = figure, hold on

    ix = find(N.msl.Time==reference_period(i))

    data = N.wvf.wvf_anomalies(:,:,ix);
    %data(data<100) = NaN; % tekið út ef það eru frávik
    data(data>-10&data<10) = NaN; % tekið út ef það eru frávik
    pcolor(double(Lon),double(Lat),data)
    shading interp % eliminates black lines between grid cells
    borders('countries','color',rgb('white'))

    set(fig, 'Color', 'k');
    ax = gca;
    set(ax, 'Color', 'k');
    set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
    set(ax, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');
    ax.XLabel.Color = 'k';
    ax.YLabel.Color = 'k';
    ax.ZLabel.Color = 'k';
    ax.Title.Color = 'k';

    %colormap('turbo')
    clim([-100  100])

    cmocean('balance','pivot',0)
    cb1 = colorbar('southoutside');
    xlabel(cb1,'Rakaflæði (vertical integral of water vapour flux) (kg/m2)')
    shading flat
    %borders('countries','color',rgb('white'))
    borders('countries','color',rgb('black'))
    borders('iceland','facecolor','white')
    quiversc(double(Lon),double(Lat),...
        N.u.u(:,:,ix).*100,...
        N.v.v(:,:,ix).*100,...
        'w','density',50)

    cb2 = newcolorbar
    contour(Lon,Lat,N.msl.msl_anomalies(:,:,ix),25,...
        'LineWidth',1)
    %colormap('jet')
    cmocean('balance','pivot',0)
    cb2 = colorbar
    xlabel(cb2,'Frávik loftþrýstings (Pa)')
    set(cb2, 'Color', 'w');
    cb2.Label.Color = 'w';

    set(cb1, 'Color', 'w');
    cb1.Label.Color = 'w';
    
    title(datestr(datetime(num2str(...
        double(N.msl.date(ix))),...
        'InputFormat', 'yyyyMMdd')),'Color','w')
    
    exportgraphics(gcf,['yfirlit_ivt_',datestr(datetime(num2str(...
        double(N.msl.date(ix))),...
        'InputFormat', 'yyyyMMdd')),'.jpg'], 'BackgroundColor', "k");

end
%%


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


