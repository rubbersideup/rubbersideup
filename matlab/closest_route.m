% returns the distance of the given crash site to the given set of routes,
% and the index of the closest route. This first finds a route's nearest
% waypoint to the crash location, and then solves for the previous and
% following line segments of that route to get the closest perpendicular
% distance from the crash site to the route. This is necessary because some
% roads are very straight and have few waypoints, and this can inflate the
% distances of crashes to infrastructure.

function [dist, ind] = closest_route(crash_lat, crash_long, routes_lats, routes_longs)

dists = zeros(1, length(routes_lats));

parfor ii=1:length(routes_lats)
    % This gets the minimum distance of the crash lat and long from a
    % waypoint on route ii. waypoint_ind is the index of the closest point
    % in the polyline to that crash point
    [dists(ii), waypoint_ind] = min(lldistkm_dw([crash_lat, crash_long], [routes_lats{ii}; routes_longs{ii}]));
end

[dist, ind] = min(dists);
