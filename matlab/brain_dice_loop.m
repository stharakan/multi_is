brns = [1,5,6,2,3,4];
is_runs = 1000;
ranks = [128,512,4096];
kas = [1 2 3];

wt_dice = -1*ones(length(brns),length(ranks),length(kas));
en_dice = wt_dice;
ed_dice = en_dice;

dnn_dice= -1*ones(length(brns),3);

for bi = 1:length(brns)
    tst_brn_idx = brns(bi);
    for ri = 1:length(ranks)
        rank = ranks(ri);
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
            
            results_filename = generate_is_results_filename(tst_brn_idx, is_runs, ka_type,rank,batches);
            if exist([results_dir,results_filename,'.mat'],'file')
                load(results_filename,'dnn_seg','seg','klr_seg', 'is_probs','brain_name','max_tumor_idx');
                fprintf('loaded %s\n',results_filename);
            else
                fprintf('cannot find %s, continuing\n',results_filename);
                continue
            end
            
            [edema_dice, enhancing_dice, whole_dice] = get_all_dice(klr_seg,seg);
            en_dice( bi,ri,ki) = enhancing_dice;
            ed_dice( bi,ri,ki) = edema_dice;
            wt_dice( bi,ri,ki) = whole_dice;
            
            [edema_dice, enhancing_dice, whole_dice] = get_all_dice(dnn_seg,seg);
            dnn_dice(bi,:) = [whole_dice, edema_dice, enhancing_dice];
            %PrintSegmentationStats(klr_seg,seg,'KLR');
            %PrintSegmentationStats(dnn_seg,seg,'DNN');
            %PrintSegmentationStats(is_seg,seg,'KLR-IS');
        end
    end
end

