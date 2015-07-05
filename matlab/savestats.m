% Outputs some csvs for loading into the stats webpage containing the
% charts, which we will render using d3. 
speed_classes = [10, 30:10:110];
speed_legend = {};
for ii=1:length(speed_classes)
    speed_legend{ii} = sprintf('%dkm/h', speed_classes(ii));
end
        
% We initially check that it's not empty, then invert the results
vstruck = ~cellfun(@isempty, {crashcsv.Total_Truck}) & ~cellfun(@isempty, {crashcsv.Total_Heavy_Truck});
vsmotorcycle = ~cellfun(@isempty, {crashcsv.Total_Motor_Cycle});
vspedestrian = ~cellfun(@isempty, {crashcsv.Total_Pedestrian});
vsother = ~cellfun(@isempty, {crashcsv.Total_Others_Vehicles});
vsanimal = ~cellfun(@isempty, {crashcsv.Total_Animal});
vehicle_classes = {'Truck', 'Motorcycle', 'Pedestrian', 'Other', 'Animal', 'Bike only'};
vsvehicle = [vstruck; vsmotorcycle; vspedestrian; vsother; vsanimal];
vsvehicle(end + 1, :) = sum(vsvehicle) == 0; % bike only - if no other vehicles involved

% Some roads have a 51km/h speed limit, we change this to 50.
% Later we need to look out for nan values for speed limits, sometimes they
% are undefined.
parsed_speeds = cellfun(@str2double, {crashcsv.SPLI_SPEED_LIMIT});
parsed_speeds(parsed_speeds == 51) = 50;

all_severity = {crashcsv.Severity};
isfatal = strcmp('Fatal', all_severity);
ishospital = strcmp('Hospital', all_severity);
ismedical = strcmp('Medical', all_severity);
% Property has two classes that both start with 'Property'
isproperty = ~cellfun(@isempty, strfind(all_severity, 'Property'));
isunknown = strcmp('Unknown', all_severity);
severity_classes = {'Fatal', 'Hospital', 'Medical', 'Property'};
isseverity = [isfatal; ishospital; ismedical; isproperty];

speed_vs_vehicle = zeros(length(vehicle_classes), length(speed_classes));
speed_vs_severity = zeros(length(severity_classes), length(speed_classes));

% Create a matrix containing different speed limit/vehicle and speed
% limit/severity combinations.
for ii=1:length(speed_classes)
    for jj=1:length(vehicle_classes)
        speed_vs_vehicle(jj, ii) = sum(vsvehicle(jj, :) .* parsed_speeds == speed_classes(ii));
    end
    
    for jj=1:length(severity_classes)
        speed_vs_severity(jj, ii) = sum(isseverity(jj, :) .* parsed_speeds == speed_classes(ii));
    end
end

clf
bar(speed_vs_severity', 'stacked');
title('Crash occurrences by severity and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false));
ylabel('Count');
legend(severity_classes);
ax = axis;
% Add 1.5 here to provide room for the legend.
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../speed_vs_severity.png';

bar(speed_vs_vehicle', 'stacked');
title('Crash occurrences by vehicle type and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Count');
legend(vehicle_classes);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../speed_vs_vehicle.png';

% Same figures but switching the grouping.
bar(speed_vs_severity, 'stacked');
title('Crash occurrences by severity and speed limit zone');
xlabel('Severity');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', severity_classes)
ylabel('Count');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_classes)+1.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../severity_vs_speed.png';

bar(speed_vs_vehicle, 'stacked');
title('Crash occurrences by vechicle and speed limit zone');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_classes)
ylabel('Count');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_classes)+2.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../vehicle_vs_speed.png';


% These are normed by speed limit, so very low or very high speed limit
% zones that do not have a lot of data can be visualised.
speed_vs_vehicle_normed = speed_vs_vehicle ./ repmat(sum(speed_vs_vehicle), [length(vehicle_classes), 1]);
speed_vs_severity_normed = speed_vs_severity ./ repmat(sum(speed_vs_severity), [length(severity_classes), 1]);

% Repeat the figures
bar(speed_vs_severity_normed', 'stacked');
title('Crash occurrences by severity and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Proportion');
legend(severity_classes);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../speed_vs_severity_normed.png';

bar(speed_vs_vehicle_normed', 'stacked');
title('Crash occurrences by vehicle type and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Proportion');
legend(vehicle_classes);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../speed_vs_vehicle_normed.png';

% Same figures but switching the grouping.
speed_vs_vehicle_transpose_normed = speed_vs_vehicle ./ repmat(sum(speed_vs_vehicle, 2), [1, length(speed_classes)]);
speed_vs_severity_transpose_normed = speed_vs_severity ./ repmat(sum(speed_vs_severity, 2), [1, length(speed_classes)]);

bar(speed_vs_severity_transpose_normed, 'stacked');
title('Crash occurrences by severity and speed limit zone');
xlabel('Severity');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', severity_classes)
ylabel('Proportion');
legend(speed_legend);
axis([0.5,5.5,0,1]);
% Save the figure as a PNG
print -dpng '../severity_vs_speed_normed.png';

bar(speed_vs_vehicle_transpose_normed, 'stacked');
title('Crash occurrences by vechicle and speed limit zone');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_classes)
ylabel('Proportion');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_classes)+2.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../vehicle_vs_speed_normed.png';



% we just dump these results to images... someone else can do some funky
% interactive thing with d3
clf
best_dist = min([best_psp_dist; best_pbn_dist; best_shared_dist]);
hist_bins = 0:0.1:10;
dist_hist = histc(best_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title('Crash occurrences by distance from bike infrastructure');
xlabel('Distance from any bike infrastructure (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_any.png';

hold off
dist_hist = histc(best_psp_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
% we get the mean distance of those that fall within this window.
title({'Crash occurrences by distance from PSP', ...
sprintf('Mean distance: %.1fkm', mean(best_psp_dist(best_psp_dist < max(hist_bins))))});
xlabel('Distance from PSP (km)');
ylabel('Count');
ax = [min(hist_bins), max(hist_bins), 0, 250]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_psp.png';

hold off
dist_hist = histc(best_pbn_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title({'Crash occurrences by distance from Perth Bike Network', ...
sprintf('Mean distance: %.1fkm', mean(best_pbn_dist(best_pbn_dist < max(hist_bins))))});
xlabel('Distance from nearest PBN route (km)');
ylabel('Count');
ax = axis;
ax = [min(hist_bins), max(hist_bins), 0, 250]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_pbn.png';

hold off
dist_hist = histc(best_shared_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title({'Crash occurrences by distance from other shared paths', ...
sprintf('Mean distance: %.1fkm', mean(best_shared_dist(best_shared_dist < max(hist_bins))))});
xlabel('Distance from shared path (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_shared.png';

% dump these all to csv files
fp = fopen('../vehicle_vs_speed.csv','w');
fprintf(fp, 'Speed');
for jj=1:length(vehicle_classes)
    fprintf(fp, ',%s', vehicle_classes{jj});
end
fprintf(fp, '\n');
for ii=1:length(speed_legend)
    fprintf(fp, '%s', speed_legend{ii});
    for jj=1:length(vehicle_classes)
        fprintf(fp, ',%d', speed_vs_vehicle(jj,ii));
    end
    fprintf(fp, '\n');
end
fclose(fp);

fp = fopen('../severity_vs_speed.csv','w');
fprintf(fp, 'Speed');
for jj=1:length(severity_classes)
    fprintf(fp, ',%s', severity_classes{jj});
end
fprintf(fp, '\n');
for ii=1:length(speed_legend)
    fprintf(fp, '%s', speed_legend{ii});
    for jj=1:length(severity_classes)
        fprintf(fp, ',%d', speed_vs_severity(jj,ii));
    end
    fprintf(fp, '\n');
end
fclose(fp);

% These are the normed versions
fp = fopen('../vehicle_vs_speed_normed.csv','w');
fprintf(fp, 'Speed');
for jj=1:length(vehicle_classes)
    fprintf(fp, ',%s', vehicle_classes{jj});
end
fprintf(fp, '\n');
for ii=1:length(speed_legend)
    fprintf(fp, '%s', speed_legend{ii});
    for jj=1:length(vehicle_classes)
        fprintf(fp, ',%.4f', speed_vs_vehicle_normed(jj,ii));
    end
    fprintf(fp, '\n');
end
fclose(fp);

fp = fopen('../severity_vs_speed_normed.csv','w');
fprintf(fp, 'Speed');
for jj=1:length(severity_classes)
    fprintf(fp, ',%s', severity_classes{jj});
end
fprintf(fp, '\n');
for ii=1:length(speed_legend)
    fprintf(fp, '%s', speed_legend{ii});
    for jj=1:length(severity_classes)
        fprintf(fp, ',%.4f', speed_vs_severity_normed(jj,ii));
    end
    fprintf(fp, '\n');
end
fclose(fp);

