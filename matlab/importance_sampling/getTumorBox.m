function [rows,cols] = getTumorBox(seg, target)

pad_row = 20;
pad_col = 20;
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


end

