% Saves the data to js file - for the format, see the ordering of the
% fields below. I was originalyl just going to save minimal data
% but fields have ended up being tacked and not necessarily in the same
% order as the original Main Roads csv... sorry :( 

is_cluster = zeros(size(crashcsv));
for ii=1:length(crashcsv)
    if sum(crash_lat(ii) == crash_lat & crash_long(ii) == crash_long) > 1
        is_cluster(ii) = 1;
    end
end

fp = fopen('../data.js', 'w');
fprintf(fp, 'var data = [\n');

for ii=1:length(crashcsv)
    fprintf(fp, '[%s,%s,"%s","%s","%s","%s","%s","%s","%s","%s",%.1f,%.1f,%.1f,"%s",%s,%s,"%s","%s",%d]', ...
    crashcsv(ii).Lat, crashcsv(ii).Long_, ...
    crashcsv(ii).Common_Road_Name(crashcsv(ii).Common_Road_Name ~= '"'), ... % no quotes in here
    crashcsv(ii).Severity, ...
    crashcsv(ii).Total_Truck, ...
    crashcsv(ii).Total_Motor_Cycle, ...
    crashcsv(ii).Total_Pedestrian, ...
    crashcsv(ii).Total_Others_Vehicles, ...
    crashcsv(ii).Total_Heavy_Truck, ...
    crashcsv(ii).Total_Animal, ...
    best_psp_dist(ii), ...
    best_pbn_dist(ii), ...
    best_shared_dist(ii), ...
    crashcsv(ii).ROAD_HIERARCHY, ... % access road, distributor etc.
    crashcsv(ii).SPLI_SPEED_LIMIT, ...
    crashcsv(ii).Year_, ...
    crashcsv(ii).Cway, ... % will be S for single, or L/R (left/right)
    crashcsv(ii).Acc_Type, ... % Currently Lights, Intersection or Midblock
    is_cluster(ii) ... % whether this is part of a cluster or not.
    );
    if ii ~= length(crashcsv)
        fprintf(fp, ',\n');
    else
        fprintf(fp, '\n');
    end
    
end
fprintf(fp, '\n];');
fclose(fp);
