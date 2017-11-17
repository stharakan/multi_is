% display results of ranking tests
close all
clearvars
misdir = getenv('MISDIR');
addpath(genpath([misdir,'/matlab']));
addpath([misdir,'/data']);
logit_flag = true;
feat_cell = {'30','60','all'};

% logit or no?
if logit_flag
    load([misdir,'/data/ranktest.logit.whiten.30.60.all.mat']); % all_accs, all_preds
    all_preds = inv_logit(all_preds);
else
    load([misdir,'/data/ranktest.30.60.all.mat']); % all_accs, all_preds
end

% preds are now between 0,1 for good vis
true_preds = all_preds(:,1);
[reo_true,reo_idx] = sort(all_preds(:,1));
reo_preds = all_preds(reo_idx,:);
tidx = reo_true > 0.75;
hidx = reo_true < 0.25;
uidx = reo_true > 0.25 & reo_true < 0.75;

histfig = figure;
[counts,edges] = histcounts(reo_preds(:,1), ...
    20,'Normalization','probability');
centers = edges(1:(end-1)) + (diff(edges)./2);
figure(histfig);
hold on;
plot(centers,counts);

featdifffig = figure;

for ff = 1:length(feat_cell)
    % histogram plot of prob distributions
    [counts,edges] = histcounts(reo_preds(:,ff+1), ...
        20,'Normalization','probability');
    centers = edges(1:(end-1)) + (diff(edges)./2);
    figure(histfig);
    plot(centers,counts);
    hold on
    
    % diff between different predictions
    diffs = abs(reo_preds(:,1) - reo_preds(:,ff+1));
    [counts,centers] = histpdf(diffs,20);
    figure(featdifffig);
    plot(centers,counts);
    hold on;
    
    % among same feature, how did different groups fare
    difffig = figure;  
    plot(centers,counts);
    legend_cell{1} = 'All';
    hold on
    
    [counts,centers] = histpdf(diffs(tidx),20);
    plot(centers,counts);
    legend_cell{2} = 'Tumor';
    hold on
    
    [counts,centers] = histpdf(diffs(hidx),20);
    plot(centers,counts);
    legend_cell{3} = 'Healthy';
    hold on
    
    [counts,centers] = histpdf(diffs(uidx),20);
    plot(centers,counts);
    legend_cell{4} = 'Mix';
    hold on
    
    title(['Absolute error for ',feat_cell{ff},' features']);
    ylabel('Probability of error');
    xlabel('Magnitude of error');
    legend(legend_cell);
    
    
end
figure(histfig);
legend([{'Truth'},feat_cell]);
title('Histogram of predicted values');
xlabel('Predicted value');
ylabel('Frequency');
hold off

figure(featdifffig);
legend(feat_cell);
title('Histograms of absolute errors');
ylabel('Probability of error');
xlabel('Magnitude of error');
hold off





