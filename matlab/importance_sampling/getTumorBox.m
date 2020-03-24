function [rows,cols] = getTumorBox(seg, target)

pad_row = 10;
pad_col = 10;
if nargin < 2
    target = 0;
end

if target
    im_mask = seg == target;
else
    im_mask = seg ~= target;
end

% create box
d1 = size(seg,1);
lin_idx = 1:numel(seg);
lin_idx = lin_idx(im_mask);
rows = unique( mod(lin_idx,d1))';
cols = unique( ceil(lin_idx/d1))';

% pad box
min_row = min(rows);
max_row = max(rows);
rows = [ ((min_row-pad_row):(min_row -1))'; ...
    rows;
    ((max_row + 1):(max_row + pad_row))'];

min_col = min(cols);
max_col = max(cols);
cols = [ ((min_col-pad_col):(min_col -1))'; ...
    cols;
    ((max_col + 1):(max_col + pad_col))'];


if length(cols) < length(rows)
    % do something
    diff = length(rows) - length(cols);
    if mod(diff,2) == 1
        rows(end + 1) = rows(end) + 1;
        diff = diff - 1;
    end
    diff2 = (diff)/2;
    cols = [ (min(cols) - diff2):(max(cols) + diff2)]';
    
elseif length(cols) > length(rows)
    % do the other
    diff = length(cols) - length(rows);
    if mod(diff,2) == 1
        cols(end + 1) = cols(end) + 1;
        diff = diff - 1;
    end
    diff2 = (diff)/2;
    rows = [ (min(rows) - diff2):(max(rows) + diff2)]';
end

if length(cols) > 240
    cols = cols(1:240);
end
if length(rows) > 240
    rows = rows(1:240);
end


% check for going out of bounds
if min(cols) < 1
    mm = min(cols);
    cols = cols - mm + 1;
end

if min(rows) < 1
    mm = min(rows);
    rows = rows - mm + 1;
end

if max(rows) > 240
    mm = max(rows);
    rows = rows - (mm - 240);
end

if max(cols) > 240
    mm = max(cols);
    cols = cols - (mm - 240);
end



end

