function potential = gaussiankerneldiag(targets, sources,sigma)
% function potential = kernel(targets, sources,sigma)
% exp( - rho.^2 ./ (2*sigma.^2 );
% potential function  

ss = sqrt(2*sigma.^2);
rho = distance(bsxfun(@ldivide,ss,targets'),bsxfun(@ldivide,ss,sources'));
potential = exp( - rho.^2 );    

end
