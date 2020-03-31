function [Q,S] = covariance_spectrum(eigenvectors, varargin)
% load klr
klr = build_klr(varargin{:});
nn = klr.nn;
cc = klr.cc;
c1 = cc - 1;

% make random vecs
sampling_p = min(eigenvectors + 40,cc *klr.mm);
xi = normrnd(0,1,nn*c1,sampling_p);

% compute product
probs = klr.KLR_Prob([]);
[Qcell,Dcell] = decomposeW(probs);
xi_out = applyRtinv_ncc(Qcell,Dcell,klr,xi);
fprintf('Computed first product\n')

% run qr on product
xi_out = reshape(xi_out,klr.mm*klr.cc,sampling_p);
[Qbig,~] = qr(xi_out,0);
fprintf('Computed first product qr\n')

% Apply Rinv_ncc
B = applyRinv_ncc(Qcell,Dcell,klr,reshape(Qbig, klr.mm,klr.cc,sampling_p));

assert(size(B,2) == sampling_p);

% Qr of b^T (we applyt the transpose in the previous step
[U,S,~] = svd(B','econ');
fprintf('Computed second product svd\n')

Q = Qbig*U;
S = diag( S(1:eigenvectors,1:eigenvectors) );
Q = Q(:,1:eigenvectors);

end

