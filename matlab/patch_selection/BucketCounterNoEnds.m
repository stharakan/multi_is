function [ counts,cell_labels,labels,inds ] = BucketCounterNoEnds( ppvec,num_divs )
%BUCKETCOUNTER counts number of elements from ppvec that are in each
%bucket. Assumptions: ppvec is between 0 and 1, and only takes values at
%multiples of (1/psize)^2. nb is set to 10 unless otherwise specified.

if nargin < 2
    num_divs = 10;
end
step = 1/num_divs;

% make buckets
buckets = 0:step:1;
nb = num_divs;
cell_labels = cell(nb,1);
counts = zeros(nb,1);
labels = zeros(size(ppvec));

% inds only if we need them
inds = 0;
if nargout > 3
    inds = cell(nb,1);
    tot_idx = 1:(length(ppvec));
end

% sort into 10 buckets (hard coded), get num
for bi = 2:(nb+1)
    % check for buckets, create labels
    bucket_idx = (ppvec >= buckets(bi-1)) & (ppvec < buckets(bi));
    cell_labels{bi-1} = [num2str(buckets(bi-1)),' - ',num2str(buckets(bi))];
    
    % sum up
    counts(bi-1) = sum(bucket_idx);
    labels(bucket_idx) = bi - 2;
    
    % inds if necessary
    if nargout > 3
        inds{bi-1} = tot_idx(bucket_idx);
    end
end



end

