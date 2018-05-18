function [Xtr,Xte] = WhitenTrnTst(Xtr,Xte)

% training first
means = mean(Xtr);
Xtr = bsxfun(@minus,Xtr, means);
stds = std(Xtr);
Xtr = bsxfun(@rdivide,Xtr,stds);

% now test
Xte = bsxfun(@minus,Xte, means);
Xte = bsxfun(@rdivide,Xte,stds);
end
