brns = [1,5,6,2,3,4];
ranks = [128];
kas = [2];
tot_brns = prod( length(brns) * length(ranks) * length(kas));

f = figure;
ha = tight_subplot(tot_brns,6,[.001,.001],[.001,.001],[.001,.001]);
tot_ims = 6*tot_brns;


for bi = 1:length(brns)
    tst_brn_idx = brns(bi);
    for rank = ranks
        for ki = kas
            ka_type = 'OneShot';
            batches = 1;
            if ki == 1
                ka_type = 'DiagNyst';
                batches = 4;
            elseif ki == 2
                ka_type = 'EnsNyst';
                batches = 4;
            end
            test_figure(tst_brn_idx, 1000, ka_type, rank, batches,ha((bi-1)*6 + (1:6)));
        end
    end
end

