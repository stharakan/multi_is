function [seg_out] = remap_klr_seg_to_labels(seg_in)

% assumes klr --> brats follows the following mapping
% 1 -> 0
% 2 -> 1
% 3 -> 2
% 4 -> 4

seg_out = seg_in - 1;
seg_out(seg_out == 3) = 4;





end