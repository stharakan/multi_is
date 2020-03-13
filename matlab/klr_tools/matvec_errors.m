function [abs_error, rel_error] = matvec_errors(X,U,L,sigma,varargin)
if length(varargin) < 2
    norm_sample_size = 1000;
    runs = 1;
else
    norm_sample_size = varargin{1};
    runs = varargin{2};
end


[d1,d2] = size(L);
dflag = (d1 == d2);
tests = 10;
[N,r] = size(U);
norm_sample_size = min(norm_sample_size, N);
smpidx = floor(1:(N/norm_sample_size):N);
smpidx = round(smpidx);

w = ones(N,1,'single')./sqrt(N);
if dflag
    uw = L*(U'*w);
else
    uw = L.*(U'*w);
end

estKw = U(smpidx,:) * uw;
if length(sigma) == 1
    truK = gaussiankernel(X(smpidx,:),X,sigma);
else
    truK = gaussiankerneldiag(X(smpidx,:),X,sigma);
end
truKw = truK*w;
N_err = norm(truKw - estKw) / norm(truKw);
%disp(['Error for weights 1/sqrt(n): ', num2str(N_err)]);

abs_error = 0;
rel_error = 0;

for j = 1:tests
    w = normrnd(0,1,[N,1]);
    w = w./norm(w);
    if dflag
        uw = L*(U'*w);
    else
        uw = L.*(U'*w);
    end
    
    
    if(runs ~=1)
        abs_error = 0;
        newN = norm_sample_size/runs;
        for i = 1:runs
            sidx = smpidx(((i-1)*newN+1):(i*newN));
            estKw = U(sidx,:) *uw;
            if length(sigma) == 1
                truKw = gaussiankernel(X(sidx,:),X,sigma)*w;
            else
                truKw = gaussiankerneldiag(X(sidx,:),X,sigma)*w;
            end
            
            abs_error = abs_error + norm(estKw - truKw); %/norm_sample_size;
            rel_error = rel_error + norm(estKw - truKw)/norm(truKw);
        end
    else
        estKw = U(smpidx,:) * uw;
        truKw = truK*w;
        err = norm(truKw - estKw);
        abs_error = abs_error + err;
        rel_error = rel_error + (err / norm(truKw)); %/norm_sample_size;
    end
end
abs_error = abs_error / tests;
rel_error = rel_error / tests;

end
