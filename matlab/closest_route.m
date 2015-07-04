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

    % Now we look at the line segments connecting the waypoints before and
    % after waypoint_ind, and find the point on each line segment that has
    % the minimum distance to the crash point. Assuming straight lines are
    % straight over a very small section of the earth!
    % we have to work in lat/long coords, can't get distance in degrees.
    best_dist = dists(ii);

    % if there is a previous waypoint
    if waypoint_ind > 1
        dist1 = seg_point_dist(crash_lat, crash_long, ...
            routes_lats{ii}(waypoint_ind), routes_longs{ii}(waypoint_ind), ...
            routes_lats{ii}(waypoint_ind - 1), routes_longs{ii}(waypoint_ind - 1));
        if dist1 < best_dist
            best_dist = dist1;
        end
    end
    
    % if there is a next waypoint
    if waypoint_ind < length(routes_lats{ii})
        dist1 = seg_point_dist(crash_lat, crash_long, ...
            routes_lats{ii}(waypoint_ind), routes_longs{ii}(waypoint_ind), ...
            routes_lats{ii}(waypoint_ind + 1), routes_longs{ii}(waypoint_ind + 1));
        if dist1 < best_dist
            best_dist = dist1;
        end
    end
    
    % just check we are actually improving the solution. We should be!
    assert(best_dist <= dists(ii));
    dists(ii) = best_dist;
end

[dist, ind] = min(dists);

% Finds the minimum distance between the crash lat/long, and the line
% segment connecting waypoint1 and waypoint2, x% of the way between the
% two. Yes there has to be a better way to do this without converting the
% actual coordinates to metres, but since I am only running this once...
function dist = seg_point_dist(crash_lat, crash_long, waypoint1_lat, waypoint1_long, waypoint2_lat, waypoint2_long)

% The way that we solve this is by using the law of cosines, where we have a
% triangle formed by the two route waypoints and the crash site.
% https://en.wikipedia.org/wiki/Law_of_cosines
% d1 is the distance from the crash site to waypoint 1 (w1)
% d2 is the distance from the crash site to waypoint 2 (w2)
% d3 is the distance from w1 to w2

% First, the angle from waypoint1 to the crash to waypoint2 must be from 90
% to 180 degrees. If it is less than 90 degrees, then we get something like
% this
%        W2 __  d2
%  d3  /      \__
%     /t2      t3 \
%   W1 ----------- CRASH
%          d1
% and then crash will be closer to the extension of the line segment W1-W2
% but the route doesn't actually go there, in which case it would be better
% to just get the distance to W2.

d1 = lldistkm_dw([crash_lat, crash_long], [waypoint1_lat, waypoint1_long]);
d2 = lldistkm_dw([crash_lat, crash_long], [waypoint2_lat, waypoint2_long]);
d3 = lldistkm_dw([waypoint1_lat, waypoint1_long], [waypoint2_lat, waypoint2_long]);

cos_t3 = (d1^2 + d2^2 - d3^2)/(2*d1*d2);
if cos_t3 > 0
    % the angle is < 90 deg, so return the dist to the closest waypoint.
    dist = min(d1, d2);
    return;
end

t2 = acos((d1^2 + d3^2 - d2^2)/(2*d1*d3));

% now we can just get the perp distance from c to the line connecting w1-w2
dist = d1*sin(t2);