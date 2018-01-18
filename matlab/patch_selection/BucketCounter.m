function [ counts,labels,inds ] = BucketCounter( ppvec,num_divs )
%BUCKETCOUNTER counts number of elements from ppvec that are in each
%bucket. Assumptions: ppvec is between 0 and 1, and only takes values at
%multiples of (1/psize)^2. nb is set to 10 unless otherwise specified.

if nargin < 2
    num_divs = 10;
end
step = 1/num_divs;

% make buckets
buckets = 0:step:1;
nb = length(buckets) + 1;
labels = cell(nb,1);
counts = zeros(nb,1);

% inds only if we need them
inds = 0;
if nargout > 2
    inds = cell(nb,1);
    tot_idx = 1:(length(ppvec));
end

% sort into 10 buckets (hard coded), get num
for bi = 1:nb
    % check for buckets, create labels
    if bi == nb
        bucket_idx = ppvec >= buckets(end) - eps; % safety
        labels{bi} = '1';
    elseif bi == 1
        bucket_idx = ppvec <= buckets(1) + eps; % just to be safe
        labels{bi} = '0';
    elseif bi == 2
        bucket_idx = (ppvec > buckets(bi-1)) & (ppvec < buckets(bi));
        labels{bi} = [num2str(buckets(bi-1)),' - ',num2str(buckets(bi))];
    else
        bucket_idx = (ppvec >= buckets(bi-1)) & (ppvec < buckets(bi));
        labels{bi} = [num2str(buckets(bi-1)),' - ',num2str(buckets(bi))];
    end
    
    % sum up
    counts(bi) = sum(bucket_idx);
    
    % inds if necessary
    if nargout > 2
        inds{bi} = tot_idx(bucket_idx);
    end
end



end

