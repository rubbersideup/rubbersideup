% Finds locations with N or more reported crashes.
% Output is dumped to the console, which I have then copied and pasted into 
% the website

[unique_lat_long, ia, ic] = unique([crash_lat', crash_long'], 'rows');
crashes_here = zeros(size(ia));

% First collate the crashes at each location.
for ii=1:length(ia)
    crashes_here(ii) = sum(ic == ii);
end


% https://developers.google.com/maps/documentation/embed/guide
% Need the space before the < a otherwise Matlab will create a link in the
% console. Not useful.
map_start = '< a href=""><img src="https://maps.googleapis.com/maps/api/staticmap?zoom=15&size=360x360&center=';
map_end = '" width="360" height="360"></a>';

num_columns = 4;
num_written = 0;

% now loop through the number of crashes in descending order.
for num_crashes=max(crashes_here):-1:3
    
    % For each location, does it have the desired number of crashes?
    for ii=1:length(ia)
    
        if crashes_here(ii) ~= num_crashes
            continue;
        end

        inds = find(ic == ii);

        % add this style to your html or stylesheet
        % .div-cell {display: inline-block; width: 300px; vertical-align: top; background-color: #dddddd; margin: 2px 2px 10px 2px}
        % .div-crash-cell {display: inline-block; vertical-align: middle; margin: 5px 10px 5px 10px}
        fprintf('<div class="div-cell">');
        
        if ~isempty(crashcsv(ia(ii)).Intx_Desc)
            fprintf('<b>%s</b>', crashcsv(ia(ii)).Intx_Desc);
        else
            fprintf('<b>%s</b>', crashcsv(ia(ii)).Common_Road_Name);
        end
        fprintf(' (%s)<br>%d crashes', crashcsv(ia(ii)).Acc_Type, crashes_here(ii));
        
        % insert static map thumbnail
        % open link in new tab
        % use HREF rather than href, otherwise Matlab will link to it in
        % the console window :S
        fprintf('<br><a HREF="https://www.google.com.au/maps/@%.8f,%.8f,15z" target="_blank">', crash_lat(ia(ii)), crash_long(ia(ii)));
        fprintf('<img src="https://maps.googleapis.com/maps/api/staticmap?zoom=15&size=360x360&center=%.8f,%.8f&markers=|%.8f,%.8f" width="270" height="270"></a>', ...
            crash_lat(ia(ii)), crash_long(ia(ii)), crash_lat(ia(ii)), crash_long(ia(ii)));
        
        % and loop through each instance at this location.
        fprintf('<br><div style="width: 100%%; text-align: center">');
        for jj=1:length(inds)
            % Each row - print the year, severity and other vehicles.
            fprintf('<div class="div-crash-cell">%s: ', crashcsv(inds(jj)).Year_);
            
            if strcmp('Fatal', crashcsv(inds(jj)).Severity)
                fprintf('<img src="icons/headstone-2.png">');
            elseif strcmp('Hospital', crashcsv(inds(jj)).Severity)
                fprintf('<img src="icons/ambulance.png">');
            elseif strcmp('Medical', crashcsv(inds(jj)).Severity)
                fprintf('<img src="icons/firstaid.png">');
            elseif ~isempty(strfind(crashcsv(inds(jj)).Severity, 'Property'))
                fprintf('<img src="icons/symbol_dollar.png">');
            else
                fprintf('<img src="icons/symbol_inter.png">');
            end
            
            if ~isempty(crashcsv(inds(jj)).Total_Truck) || ~isempty(crashcsv(inds(jj)).Total_Heavy_Truck)
                fprintf('<img src="icons/truck3.png">');
            end

            if ~isempty(crashcsv(inds(jj)).Total_Motor_Cycle)
                fprintf('<img src="icons/ducati-diavel.png">');
            end

            if ~isempty(crashcsv(inds(jj)).Total_Pedestrian)
                fprintf('<img src="icons/hiking.png">');
            end
            
            if ~isempty(crashcsv(inds(jj)).Total_Others_Vehicles)
                fprintf('<img src="icons/car.png">');
            end
            fprintf('</div>');
        end
        fprintf('</div><!-- individual crash -->');
        fprintf('</div><!-- crash hotspot -->\n');
    end
end
