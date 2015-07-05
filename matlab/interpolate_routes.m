function [routes_lats, routes_longs] = interpolate_routes(routes_lats, routes_longs)

% we interpolate the routes here between the waypoints.
parfor ii=1:length(routes_lats)
    altered_lats = routes_lats{ii}(1);
    altered_longs = routes_longs{ii}(1);
    
    for jj=1:length(routes_lats{ii})-1
        this_lat = routes_lats{ii}(jj);
        this_long = routes_longs{ii}(jj);
        next_lat = routes_lats{ii}(jj+1);
        next_long = routes_longs{ii}(jj+1);
        
        % if it is more than 200m betwen waypoints, we interpolate it linearly
        this_dist = min(lldistkm_dw([this_lat, this_long], [next_lat, next_long]));
        if this_dist > 0.2
            num_segs = floor(this_dist * 10);
            alpha = (1:num_segs) / num_segs;
            altered_lats = [altered_lats, this_lat + alpha * (next_lat-this_lat)];
            altered_longs = [altered_longs, this_long + alpha * (next_long-this_long)];
        else
            altered_lats(1, end+1) = next_lat;
            altered_longs(1, end+1) = next_long;
        end
    end
    routes_lats{ii} = altered_lats;
    routes_longs{ii} = altered_longs;
end
