function [ nn_dist_scaled ] = NNDistanceScaleToRank( nn_dist,bw_rank,bw_scale )
%NNDISTANCESCALETORANK scales an nn x kk matrix nn_dist of distance to
%nearest neighbors by dividing by a variable bandwidth. The bandwidth is
%selected by using the distance given by the bw_rank^th neighbor distance.
%This can be additionally scaled by the thrid arg bw_scale. Default
%bw_scale = 1.

if nargin == 2
    bw_scale = 1;
end

% get variable bws
bws = nn_dist(:,bw_rank).*bw_scale;

% set up exponential matrix
nn_dist_scaled = bsxfun(@rdivide,nn_dist,bws);


end

