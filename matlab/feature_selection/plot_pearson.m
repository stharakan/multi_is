% load scores, initialize cells
load('/Users/sameer/Desktop/pearson_scores_wstats_50M.mat');
mod_cell = {'FLAIR','T1','T1CE','T2'};
ang_cell = {'0','22.5','45','67.5','90','112.5','135','157.5'};
stat_cell = {'avg','max','med','std'};
bw_cell = {'2','4','8','16','32'};

% compute all other quantities from cell arrays
modalities = length(mod_cell);
angles = length(ang_cell);
bws = length(bw_cell);
stat_features_per_filter = length(stat_cell);
features_per_filter = stat_features_per_filter + angles;
tot_feats = length(trn_pscores);
feats_per_modality = tot_feats/modalities;
filters_per_modality = feats_per_modality/(features_per_filter);
tot_filters = tot_feats/features_per_filter;

% loop over filters and plot?
for mi = 1:modalities
    filterplot = figure;
    cur_mod = mod_cell{mi};
    
    for bi = 1:bws
        idx_num = (mi-1)*filters_per_modality + bi;
        cur_bw = bw_cell{bi};
        
        % plot
        fi_idx = (1:features_per_filter) + (idx_num-1)*features_per_filter;
        plot(abs(trn_pscores(fi_idx)));
        hold on
        
        % add to legend
        legcell{bi} = sprintf('bw-%s',cur_bw);
    end
    
    legend(legcell,'Location','best');
    set(gca,'XTick',1:features_per_filter,'XTickLabel',[ang_cell,stat_cell]);
    title(sprintf('Absolute Pearson scores for %s',cur_mod));
    xlabel('Angle/statistic');
    ylabel('Absolute Pearson coefficient');
    hold off;
    
end


