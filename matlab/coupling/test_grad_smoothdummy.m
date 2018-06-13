function [] = test_grad_smoothdummy(weights,noises,mflag,smoothing_bw) 

if ~exist('weights','var')
  weights = logspace(-1,4,6);
elseif isempty(weights)
  weights = logspace(-1,4,6);
end

if ~exist('noises','var')
  noises = 0.2;
end

if nargin < 3
	mflag = true;
elseif isempty(mflag)
	mflag = true;
end

if nargin < 4
	smoothing_bw = 1;
end


if mflag 
	bg_base = 1;
	sv_string = './grad_smoothdummy_more_vars.mat';
else
	bg_base = 2;
	sv_string = './grad_smoothdummy_less_vars.mat';
end


% Testing on toy problem
sz = 50;nzidx = 20:30;
bws = [10 0.5 1];
crfiters = 10;

% toy prob init
seg = zeros(sz);
seg(nzidx,nzidx) = 1;
im = bg_base + randn(sz);
im(nzidx,nzidx) = 4 + randn(length(nzidx));

Ts = cell(length(noises) * length(weights) ,1);
all_kl = zeros( sz,sz, length(noises) * length(weights));
all_q = zeros( sz,sz, length(noises) * length(weights));
all_pre = zeros( sz,sz, length(noises));

for nn = 1:length(noises)

noise = noises(nn);

% create SMOOTH probs
probs = CreateDummyProbabilities(seg,1,noise,0.75);
probs = imgaussfilt(probs,smoothing_bw);


unary = [probs(:), 1 - probs(:)];

for ww = 1:length(weights)
  weight = weights(ww);

% crf obj
crf = DenseCRFExact(im,bws,[],unary,weight);

% dice init
predice = ComputeDiceScore(seg(:),round(unary(:,1)),1);
preacc = sum(seg(:) == round(unary(:,1)))/numel(seg);
[pref,preg] = crf.FunctionAndGradient(unary);
pregn = norm(preg,'fro');
PRE = [predice;preacc;pref;pregn];


% iterations
tic; qf = KLMinIterateCRF(crf,crfiters,[],seg); kltime = toc;
kldice = ComputeDiceScore(seg(:),round(qf(:,1)),1);
klacc = sum(seg(:) == round(qf(:,1)))/numel(seg);
[klf,klg] = crf.FunctionAndGradient(qf);
klgn = norm(klg,'fro');
KL = [kldice;klacc;klf;klgn];

tic; qf_qua = QuasiIterateCRF(crf,crfiters,[],seg,0); quatime = toc;
quadice = ComputeDiceScore(seg(:),round(qf_qua(:,1)),1);
quaacc = sum(seg(:) == round(qf_qua(:,1)))/numel(seg);
[quaf,quag] = crf.FunctionAndGradient(qf_qua);
quagn = norm(quag,'fro');
Q = [quadice;quaacc;quaf;quagn];

tic; qf_qkl = QuasiIterateCRF(crf,crfiters,qf,seg,0); qkltime = toc;
qkldice = ComputeDiceScore(seg(:),round(qf_qkl(:,1)),1);
qklacc = sum(seg(:) == round(qf_qkl(:,1)))/numel(seg);
[qklf,qklg] = crf.FunctionAndGradient(qf_qkl);
qklgn = norm(qklg,'fro');
QKL = [qkldice;qklacc;qklf;qklgn];

Stat = {'Dice';'Acc';'|g|';'f'};

cur_idx = (nn-1)*length(weights) + ww;
all_kl(:,:,cur_idx) = reshape(qf(:,1),size(im));
all_q(:,:,cur_idx) = reshape(qf_qua(:,1),size(im));
all_pre(:,:,nn) = reshape(probs,size(im));

Strs{cur_idx} = sprintf('Weight: %d, Noise %5.2f',weight,noise);
Ts{cur_idx} = table(Stat,PRE,KL,Q,QKL);
WW{cur_idx} = weight;
NN{cur_idx} = noise;

end
end

save(sv_string,'im','seg','all_pre','all_kl','all_q','Ts','WW','NN');

for tt = 1:length(Ts)
   disp('-----------------');
   disp(Strs{tt})
   T = Ts{tt}
   disp('-----------------');
end




%fprintf('Pre dice: %4.2f\n',predice);
%fprintf('Pre acc : %4.2f\n',preacc);
%fprintf('------------------\n');
%fprintf('KL dice: %4.2f\n',kldice);
%fprintf('KL acc : %4.2f\n',klacc);
%fprintf('KL time: %4d\n',kltime);
%fprintf('------------------\n');
%fprintf('Q dice: %4.2f\n',quadice);
%fprintf('Q acc : %4.2f\n',quaacc);
%fprintf('Q time: %4d\n',quatime);

end
