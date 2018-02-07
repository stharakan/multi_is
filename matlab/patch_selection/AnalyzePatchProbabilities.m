function [] = AnalyzePatchProbabilities(blist,psize,target,outdir)

save_flag = true;
% check outdir
if nargin < 4
	outdir = '';
	save_flag = false;
end

% print info
fprintf('Analyzing patch probabilities ...\n');
fprintf('target: %d\npsize: %d\ndir: %s\n',target,psize,outdir);

% find ppvec
ppvec = GetPatchProbabilities(blist,psize,target,outdir);

% make vecs for later
smallest_inc = 1/psize^2;
endpoint_vec = [0,smallest_inc,0.1:0.1:0.9,1 - smallest_inc+eps,1+eps]';
num_divs = length(endpoint_vec) - 1;
all_abs = zeros(num_divs,blist.num_brains);
all_percs = all_abs;

% print headers for brain stuff
strs = {'0-10  ','10-20 ','20-30 ','30-40 ','40-50 ','50-60 ', ... 
	'60-70 ','70-80 ','80-90 ','90-100'};
all_strs = [{'0     '},strs,{'100   '}]; %TODO use bucket funcs

if ~target
    all_strs = flip(all_strs);
    strs = flip(strs);
    endpoint_vec = flip(endpoint_vec);
end
    
% loop over brains, print stats along the way
for bi = 1:blist.num_brains
	% extract
	cur_idx = blist.WithinTotalIdx(bi); 
	pp_cur = ppvec(cur_idx);
    ppb = length(pp_cur);
    
    cur_abs = zeros(num_divs,1);
    for ni = 1:num_divs
        if target 
            num_cur = sum(pp_cur >= endpoint_vec(ni) & pp_cur < endpoint_vec(ni+1));
        else
            num_cur = sum(pp_cur < endpoint_vec(ni) & pp_cur >= endpoint_vec(ni+1));
        end
		cur_abs(ni) = num_cur;
		all_abs(ni,bi) = num_cur;
    end
    all_percs(:,bi) = cur_abs./ppb;
    
    % set up print output
    pp_vec = cur_abs./ppb;
    sum_val = sum(pp_vec(2:end));
    if sum_val ~=0
    	pp_vec(2:end) = pp_vec(2:end)./sum(pp_vec(2:end));
    end
    
	% print histogram results
	fprintf('\n%s\n',blist.brain_cell{bi});
	fprintf(' Bucket | Perc | Abs \n');
    fprintf(' %s | %3.2f | %d\n -------------------\n',all_strs{1},all_percs(1,bi),all_abs(1,bi));
	for ni = 2:(num_divs)
		fprintf(' %s | %3.2f | %d\n',all_strs{ni},pp_vec(ni),all_abs(ni,bi));
    end
end

% average out things
mean_abs = mean(all_abs,2);
mean_percs(1) = mean(all_percs(1,:));
pmat = all_percs(2:end,:);
sum_percs = sum(pmat);
sum_percs(sum_percs == 0) = 1;
pmat = bsxfun(@rdivide,pmat,sum_percs);
mean_percs(2:(num_divs)) = mean( pmat,2 );

% print averages for general idea
fprintf('\n%s\n','Average over all brains');
fprintf(' Bucket | Perc | Abs \n');
fprintf(' %s | %3.2f | %d\n -------------------\n',all_strs{1},mean_percs(1),mean_abs(1));
for ni = 2:(num_divs)
	fprintf(' %s | %3.2f | %d\n',all_strs{ni},mean_percs(ni),mean_abs(ni));
end

% flip, make boxplots
all_percs = all_percs';
all_abs = all_abs';

percs0_fig = figure;
cur_sum = sum(all_percs(:,2:end),2);
cur_mat = bsxfun(@rdivide,all_percs(:,2:end),cur_sum);
boxplot(cur_mat);
set(gca,'XTick',1:(num_divs-1),'XTickLabel',all_strs(2:end));
title('Box plot of percentages over brains w/o main end');
xlabel('Bucket');
ylabel('Percentage');

abs_fig01 = figure;
boxplot(all_abs(:,2:(end-1)));
set(gca,'XTick',1:(num_divs-2),'XTickLabel',strs);
title('Box plot of absolute vals over brains w/o ends');
xlabel('Bucket');
ylabel('Num pixels');

abs_fig = figure;
boxplot(all_abs);
set(gca,'XTick',1:(num_divs),'XTickLabel',all_strs);
ylim( [min(all_abs(:)), max(all_abs(:))]);
set(gca,'yscale','log');
title('Box plot of absolute vals over brains');
xlabel('Bucket');
ylabel('Num pixels');

% save figures
if save_flag
    savefig([abs_fig,abs_fig01,percs0_fig],[outdir,blist.MakePPvecAnalyzeFile(psize,target)]);
end


end
