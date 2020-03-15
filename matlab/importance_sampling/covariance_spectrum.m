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

% run qr on product
xi_out = reshape(xi_out,klr.mm*klr.cc,sampling_p);
[Qbig,~] = qr(xi_out,0);

% Apply Rinv_ncc
B = applyRinv_ncc(Qcell,Dcell,klr,reshape(Qbig, klr.mm,klr.cc,sampling_p));

% Qr of b^T (we applyt the transpose in the previous step
[U,S,~] = svd(B',0);

Q = Qbig*U;
S = diag( S(1:eigenvectors,1:eigenvectors) );
Q = Q(:,1:eigenvectors);

end

