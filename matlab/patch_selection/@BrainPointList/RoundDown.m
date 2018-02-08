function [ blist_out ] = RoundDown( blist,pof10 )
%ROUNDDOWN rounds the total number of points in the brainpointlist obj down
%to the nearest 10^pof10. The points are randomly subsampled from each
%brain to preserve brain-to-brain proportions. Default pof10 is 5.

if nargin == 1
    pof10 = 5; % nearest 100k
end

% figure out new total pts
blist_out = blist; % pt_selector, brain_dir, pts_per_brain,brain_cell,tot_points
nb = blist.num_brains;
tp = blist.tot_points;
new_tp = round(tp,-pof10);
ss_factor = new_tp/tp;
blist_out.tot_points = new_tp; % num_brains

% set new index lengths
orig_idx_lengths = cellfun('length',blist.pt_inds);
tru_idx_lengths = orig_idx_lengths .* ss_factor;
ss_idx_lengths = floor(tru_idx_lengths);

ss_tp = sum(ss_idx_lengths);
ss_dif = new_tp - ss_tp;

if ss_dif
    [~,brn_up_idx] = sort(tru_idx_lengths - ss_idx_lengths,'descend');
    brn_up_idx = brn_up_idx(1:ss_dif);
    ss_idx_lengths(brn_up_idx) = ss_idx_lengths(brn_up_idx) + 1;
    
    if sum(ss_idx_lengths) ~= new_tp
        error('new index calculation error');
    end
end

% loop through and truncate to get pt_inds
blist_out.pt_inds = cell(nb,1);
for bi = 1:nb
    idx = randsample(blist.pt_inds{bi},ss_idx_lengths(bi));
    blist_out.pt_inds{bi} = idx;
end

blist_out.brn_markers = zeros(nb + 1,1);
blist_out.brn_markers(2:end) = cumsum(ss_idx_lengths); % brn_markers



end

