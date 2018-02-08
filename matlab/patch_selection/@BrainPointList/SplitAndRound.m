function [ trn,tst ] = SplitAndRound( blist,sperc,pof10 )
%SPLITANDROUND rounds the training/test list after splitting them, allowing
%the list to be ready to be processed by knn/askit. 

if nargin < 2 
    sperc = 0.8;
end

if nargin < 3 
    pof10 = 5;
end

% split
[trn_all,tst_all] = blist.Split(sperc);

% round
trn = trn_all.RoundDown(pof10);
tst = tst_all.RoundDown(pof10);

end

