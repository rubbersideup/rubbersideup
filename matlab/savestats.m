% Outputs some csvs for loading into the stats webpage containing the
% charts, which we will render using d3. 
speed_classes = [10, 30:10:110];

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
severity_classes = {'Fatal', 'Hospital', 'Medical', 'Property', 'Unknown'};
isseverity = [isfatal; ishospital; ismedical; isproperty; isunknown];

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
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Count');
legend(severity_classes);
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
print -dpng '../speed_vs_vehicle.png';



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
print -dpng '../speed_vs_severity_normed.png';

bar(speed_vs_vehicle_normed', 'stacked');
legend(vehicle_classes);
title('Crash occurrences by vehicle type and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Proportion');
legend(vehicle_classes);
print -dpng '../speed_vs_vehicle_normed.png';


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

% todo: dump to a csv
