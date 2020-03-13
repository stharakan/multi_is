function [Q,D] = decomposeW(probs)

% Form W
probs = NormalizeClassProbabilities(probs);
W_ncc = composeW_ncc(probs);

% initialize matrices
[nn,cc] = size(probs);
Q = cell(nn,1);
D = cell(nn,1);

for ni = 1:nn
    % extract current idx
    start_idx = (ni-1)*cc + 1;
    end_idx = ni*cc;
    cur_W = W_ncc(start_idx:end_idx,:);
    
    % compute current decomp
    [Q_i, D_i] = eig(cur_W,'vector');
    [~,sort_idx] = sort(D_i, 'descend');
    keep_idx = sort_idx(1:(cc-1));
    
    % load
    Q{ni} = Q_i(:,keep_idx);
    D{ni} = D_i(keep_idx);
    %Q(start_idx:end_idx,:) = Q_i;
    %D(start_idx:end_idx) = diag(D_i);
end

end

