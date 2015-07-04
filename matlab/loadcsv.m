% loadcsv
%
% Function to parse a CSV file into a struct array. This differs from
% Matlab's csvread() mainly in that it returns a struct array, one element
% per row, instead of a matrix, and CSV cells can contain strings. Struct
% elements are stored using the header string of each column (though if the
% header is invalid i.e. containing a space or starting with a digit or _
% it will silently discard that column).
%
% Usage: rows = mavi_loadcsv(filename)
% where rows is a struct array, one array element per row of filename.

function rows = loadcsv(filename)

fp = fopen(filename, 'r');
row = 0;

% Load each row into an array element.
while ~feof(fp)
    thisline = strtrim(fgets(fp));
    row = row + 1;
    
    % read tokens
    tokens = {};
    while ~isempty(thisline)
        if thisline(1) == '"'
            % Need a special case here for escaped double quotes - if there
            % is a double quote inside a string, "" is used to escape it.
            idx = find(thisline(2:end) == '"');
            while length(idx) > 1
                % remove this instance and try again.
                if idx(2) == idx(1) + 1
                    idx = idx(3:end);
                else
                    % it is not a double quote. just take the index of this
                    % quote and use it.
                    idx = idx(1);
                end
            end
            if isempty(idx)
                fclose(fp);
                error('Invalid file format (missing ''"'')');
            end
            tokens{end+1} = thisline(2:idx);
            % next token
            thisline = thisline(idx+2:end);
            % if not the last element.
            if length(thisline) > 1
                if thisline(1) == ','
                    thisline = thisline(2:end);
                else
                    fclose(fp);
                    error('Invalid file format (missing '','')');
                end
            end
        else
            idx = find(thisline == ',', 1);
            if isempty(idx)
                idx = length(thisline);
                tokens{end+1} = thisline(1:idx);
            else
                tokens{end+1} = thisline(1:idx-1);
            end            
            % next token
            thisline = thisline(idx+1:end);
        end
    end
    
    if row == 1
        column_headers = tokens;        

        % Which columns have a valid name?
        valid_field_name = true(size(column_headers));
        for ii=1:length(column_headers)
            % check that it doesn't start with a digit or underscore, 
            % or contain a space or parentheses
            if column_headers{ii}(1) >= 0 && column_headers{ii}(1) <= 9 || ...
                    column_headers{ii}(1) == '_' || ...
                any(column_headers{ii} == '(') || any(column_headers{ii} == ' ')
                valid_field_name(ii) = 0;
            end
        end

        continue;
    end

    % It seems that the last column may be discarded.
    if length(tokens) == length(column_headers) - 1
       tokens{end+1} = '';
    end
    if ~isempty(tokens) && length(tokens) > length(column_headers)
        fclose(fp);
        error('Invalid file format (wrong number of columns)');
    end
    
    % all elements of the cell array are empty - don't process this row
    if all(cellfun(@isempty, tokens))
        continue;
    end
    
    % map the columns to the struct
    this_row = cell2struct(tokens(valid_field_name), column_headers(valid_field_name), 2);
    
    % Add to the list of read rows.
    if exist('rows')
        rows(end+1) = this_row;
    else
        rows = this_row;
    end
end

fclose(fp);