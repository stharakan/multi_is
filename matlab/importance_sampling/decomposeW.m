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
    [Q_i, D_i] = eig(cur_W);
    
    % load
    Q{ni} = Q_i(:,1:(cc-1));
    D{ni} = diag(D_i(1:(cc-1),1:(cc-1)));
    %Q(start_idx:end_idx,:) = Q_i;
    %D(start_idx:end_idx) = diag(D_i);
end

end

