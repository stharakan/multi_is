% load scores, initialize cells
addpath(genpath('./'));
addpath('./../data/');
prob_type = 'reg';
C = .1;
mod_cell = {'FLAIR','T1','T1CE','T2'};
ang_cell = {'0','22.5','45','67.5','90','112.5','135','157.5'};
ang_cell = {};
stat_cell = {'avg','max','med','std','l2','l1'};
bw_cell = {'2','4','8','16','32'};

% fig dir
fig_dir = './../data/figs/';
mkdir(fig_dir);
%load(['./../data/ftranks.reg.C.',num2str(C),'.nn.1000000.mat']);
load(['./../data/fr.onlystats.reg.C.',num2str(C),'.nn.1000000.mat']);

% compute all other quantities from cell arrays
modalities = length(mod_cell);
angles = length(ang_cell);
bws = length(bw_cell);
stat_features_per_filter = length(stat_cell);
features_per_filter = stat_features_per_filter + angles;
tot_feats = size(ftRank,1);
feats_per_modality = tot_feats/modalities;
filters_per_modality = feats_per_modality/(features_per_filter);
tot_filters = tot_feats/features_per_filter;

% sort and get indices
[~,feat_importances] = sort(ftRank);
feat_importances = feat_importances';

% loop over filters and plot?
for bi = 1:bws
    filterplot = figure;
    cur_bw = bw_cell{bi};
    
    for mi = 1:modalities
        
        idx_num = (mi-1)*filters_per_modality + bi;
        cur_mod = mod_cell{mi};
        
        % plot
        fi_idx = (1:features_per_filter) + (idx_num-1)*features_per_filter;
        subplot(2,2,mi);
        boxplot(feat_importances(:,fi_idx));
        
        % add to legend
        %legcell{bi} = sprintf('bw-%s',cur_bw);
        %legend(legcell,'Location','best');
        set(gca,'XTick',1:features_per_filter,'XTickLabel',[ang_cell,stat_cell]);
        title(sprintf('%s ranks for %s, freq %s',prob_type,cur_mod,cur_bw));
        xlabel('Angle/statistic');
        ylabel('SVM-RFE Rank');
        ylim([1 tot_feats]);        
    end
    
    title_str = sprintf('ftr.%s.c%2.1f.fr%s',prob_type,C,cur_bw);
    filterplot.PaperUnits = 'inches';
    orient(filterplot,'landscape');
    %print(filterplot,'-djpeg',[fig_dir,title_str]);
    %saveas(filterplot,[fig_dir,title_str,'.jpg']);
    %print(filterplot,'-depsc','-loose',[fig_dir,title_str]);
    saveas(filterplot,[fig_dir,title_str,'.eps']);
    %print(filterplot,[fig_dir,title_str],'-dpdf');
    
    
end


