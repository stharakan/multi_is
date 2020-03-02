function [slice_index] = MaxTumorSlice(brain,target)
if nargin < 2
    target = -1;
end

seg = brain.ReadSeg();
seg = reshape(seg,[],size(seg,3)); % assume seg 3d

if target == -1
    seg_sums = sum(seg > 0);
else
    seg_sums = sum(seg == target);
end

[max_num_pixels,slice_index] = max(seg_sums);

end

