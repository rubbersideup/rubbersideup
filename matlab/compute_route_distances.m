% this sub-script computes the distances of all the 3 route sets to each
% crash site.

% preallocate
best_shared_ind = zeros(size(crash_lat));
best_pbn_ind = zeros(size(crash_lat));
best_psp_ind = zeros(size(crash_lat));

best_shared_dist = zeros(size(crash_lat));
best_pbn_dist = zeros(size(crash_lat));
best_psp_dist = zeros(size(crash_lat));

% now for each crash location we want to find the closest coordinate of a
% path. Loop through each path and find the nearest coordinate. Then we
% will store the best
for ii=1:length(crash_lat)
    if mod(ii,100) == 0
        fprintf('crash %d\n', ii);
    end
    this_lat = crash_lat(ii);
    this_long = crash_long(ii);
    
    % See the comments in closest_route for how this is calculated
    [best_shared_dist(ii), best_shared_ind(ii)] = closest_route(this_lat, this_long, shared_lats, shared_longs);
    [best_pbn_dist(ii), best_pbn_ind(ii)] = closest_route(this_lat, this_long, pbn_lats, pbn_longs);
    [best_psp_dist(ii), best_psp_ind(ii)] = closest_route(this_lat, this_long, psp_lats, psp_longs);
end

% Save the results as it can take a while to run (20 mins or so)
save routedists.mat best_shared_dist best_shared_ind best_pbn_dist best_pbn_ind best_psp_dist best_psp_ind 