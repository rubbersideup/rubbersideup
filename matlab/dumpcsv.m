% Function to dump a matrix to CSV. This is rather straight-forward.

function dumpcsv(filename, col_labels, row_labels, data)

[rows, cols] = size(data);
assert(length(col_labels) == cols);
assert(length(row_labels) == rows);

fp = fopen(filename,'w');
for jj=1:length(col_labels)
    fprintf(fp, ',%s', col_labels{jj});
end
fprintf(fp, '\n');
for ii=1:length(row_labels)
    fprintf(fp, '%s', row_labels{ii});
    for jj=1:length(col_labels)
        fprintf(fp, ',%.4f', data(ii,jj));
    end
    fprintf(fp, '\n');
end
fclose(fp);