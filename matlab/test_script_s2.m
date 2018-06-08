clearvars -except noise weight
close all

% % Testing probability saving/reading
outdir = getenv('PRDIRSCRATCH');
bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
bcell = GetBrnList(bdir);
bcell = bcell(2);
bcell = {'Brats17_TCIA_621_1'};
ps = PointSelector('sliceedemamax',1);
blist = BrainPointList(bdir,bcell,ps,'');

%brn = blist.MakeBrain(1);
%pstr = 'tstprobs.t.2';
%pdir = './';
%bws = [5 0.2 1];
%slice = 59;
%conf = 0.75; err = 0.15;
%
%% disp('Creating probs');
%%[Pmat] = CreateDummyProbabilities(brn,2,err,conf);
%%
%%disp('Saving probs');
%%brn.SaveProbs(Pmat,outdir,pstr);
%
%disp('Running quasi');
%tic; Pf = CRFSingleBrain(brn,outdir,pstr,1/4,bws,'quasi'); toc

%disp('Running klmin');
%tic; Pf = CRFSingleBrain(brn,outdir,pstr,1/4,bws,'klmin');toc 

%% dice init
%predice = ComputeDiceScore(seg(:),round(unary(:,1)),1);
%preacc = sum(seg(:) == round(unary(:,1)))/numel(seg);
%
%% iterations
%tic; qf = KLMinIterateCRF(crf,crfiters,[],seg); kl_time = toc;
%kldice = ComputeDiceScore(seg(:),round(qf(:,1)),1);
%klacc = sum(seg(:) == round(qf(:,1)))/numel(seg);
%
%%tic; qf_qua = QuasiIterateCRF(crf,crfiters,[],seg,0); qua_time = toc;
%%tic; qf_qua = QuasiIterateCRF(crf,crfiters,qf,seg,0); qua_time = toc;
%qudice = ComputeDiceScore(seg(:),round(qf_qua(:,1)),1);
%quacc = sum(seg(:) == round(qf_qua(:,1)))/numel(seg);
%
%
%fprintf('Pre dice: %4.2f\n',predice);
%fprintf('Pre acc : %4.2f\n',preacc);
%fprintf('------------------\n');
%fprintf('KL dice: %4.2f\n',kldice);
%fprintf('KL acc : %4.2f\n',klacc);
%fprintf('KL time: %4d\n',kl_time);
%fprintf('------------------\n');
%fprintf('Q dice: %4.2f\n',qudice);
%fprintf('Q acc : %4.2f\n',quacc);
%fprintf('Q time: %4d\n',qua_time);

% Testing on toy problem
sz = 50;nzidx = 20:30;
bws = [10 0.2 1];
crfiters = 3;

% toy prob init
seg = zeros(sz);
seg(nzidx,nzidx) = 1;
im = 1 + randn(sz);
im(nzidx,nzidx) = 4 + randn(length(nzidx));
im = double(im);
probs = CreateDummyProbabilities(seg,1,noise,0.75);
probs = double(probs);
unary = [probs(:), 1 - probs(:)];
unary = NormalizeClassProbabilities(unary); 
unary = double(unary);
m = 1 - eye(size(unary,1));
m = 1 - eye(numel(unary));
m = bsxfun(@rdivide,m,sum(m,2));

% crf obj
%crf = DenseCRFExact(im,bws,[],unary,weight);
%fun = @(Q) crf.FunctionAndGradient(Q);


options = optimoptions(@fminunc,'MaxIterations',crfiters,'Display','iter-detailed','SpecifyObjectiveGradient',true,'OptimalityTolerance',1e-10,'FiniteDifferenceType','central','CheckGradient',true);
fun = @(Q) crfobj(Q,unary(:),m);
hInit = eps^(1/3);
randstart = 10 + rand(size(unary(:)));
unstart = unary(:);

disp('------------------')
[grad, err] = myGrad(@crfobj2, randstart, hInit);
[f, grad2,f2] = crfobj2(randstart);


%fprintf('Random f1 vs f2: %5.3f  %5.3f\n',f,f2);
fprintf('Random Rel grad: %5.3f\n',norm(grad(:) - grad2(:))/norm(grad2(:)));
disp('------------------')

% try with unary starting
[grad, err] = myGrad(@crfobj2, unstart, hInit);
[f, grad2,f2] = crfobj2(unstart);
%fprintf('Unary f1 vs f2: %5.3f  %5.3f\n',f,f2);
fprintf('Unary Rel grad: %5.3f\n',norm(grad(:) - grad2(:))/norm(grad2(:)));
disp('------------------')

%symold = sym( @crfobj2);
%symold = sym( @crfobj3);
%old = @(q) q' * log(q);
%symold = sym(old);
%rnsym = sym(randstart);
%unsym = sym(unstart);


%[qf,fval,eflag,output,grad] = fminunc(@crfobj2,double(unary(:)),options);

%[qf,fval,eflag,output,grad] = fminunc(@crfobj,randstart,options);

%options = optimoptions(@fminunc,'MaxIterations',crfiters,'Display','iter-detailed','SpecifyObjectiveGradient',true,'OptimalityTolerance',1e-10);
%[qf2,fval2,eflag2,output2,grad2] = fminunc(fun,double(unary),options);


function [f, g] = crfobj(q,u,W)
	%m = W * q;  

	% overall
	%obj_sum = m./2 + log( q ) - log( u );
	%g = m + 1 + log(q) - log(u);
	
	% just entropy
	e_obj_sum = log(q);
	e_g = log(q) + 1; 
	
	% just unary
	%u_obj_sum =- log( u );
	%u_g = - log(u);
	%
	%% just pairwise
	%p_obj_sum = m./2;
	%p_g = m;

	obj_sum = e_obj_sum;
	g = e_g;
	%obj_sum = e_obj_sum + p_obj_sum + u_obj_sum;
	%g = e_g + p_g + u_g;
	f = obj_sum.*q; f = sum(f(:));
        
end

function [f2, g,f] = crfobj3(q)
	f = q' * log(q);
	g = log(q) + 1;

        qlogq = q.*log(q);
	[m,i] = max( abs(qlogq) );
	
	maxval = qlogq(i);
	qlogq = qlogq - maxval;
	inner = sum(qlogq) + 1;
	f2 = maxval + log(inner);
end

function [f, g,f2] = crfobj2(q)
	f = q' * log(q);
	g = log(q) + 1;

        qlogq = q.*log(q);
	[m,i] = max( abs(qlogq) );
	
	maxval = qlogq(i);
	qlogq = qlogq - maxval;
	inner = sum(qlogq) + 1;
	f2 = maxval + log(inner);
end
