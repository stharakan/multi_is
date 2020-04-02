brns = [1,5,6,2,3,4];
ranks = [128,512,4096];
kas = [1,2,3];
extra_str= 'coronal';
is_runs = 1000;

% fixed vars
data_locations;
tot_brns = prod( length(brns) * length(ranks) * length(kas));


% set up figure
%fmain = figure;
%ha = tight_subplot(tot_brns,6,[.001,.001],[.001,.001],[.001,.001]);


tot_ims = 6*tot_brns;

% loop and create
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
        % set up filenames
        basefilename = generate_klr_filename(ka_type,rank,batches);
        if ~(strcmp(extra_str,''))
            basefilename = [basefilename,'-',extra_str];
        end
        basefilename
        
        
        fmain = figure;
        ha = tight_subplot(tot_brns,6,[.001,.001],[.001,.001],[.001,.001]);

        for bi = 1:length(brns)
            tst_brn_idx = brns(bi);
            brain_base = generate_is_results_filename(tst_brn_idx,is_runs,...
                ka_type,rank,batches);
            if ~(strcmp(extra_str,''))
                brain_base = [brain_base,'-',extra_str];
            end
            
            % plot dim 1 constant
            d1_fig = figure;
            line_plot_figure(1,tst_brn_idx,is_runs,extra_str,ka_type,rank,batches);
            savefig(d1_fig,[image_dir,brain_base,'_d1.fig']);
            print([image_dir,brain_base,'_d1.png'],'-dpng');
            close(d1_fig);
            
            % dim 2
            d2_fig = figure;
            line_plot_figure(2,tst_brn_idx,is_runs,extra_str,ka_type,rank,batches);
            savefig(d2_fig,[image_dir,brain_base,'_d2.fig']);
            print([image_dir,brain_base,'_d2.png'],'-dpng');
            close(d2_fig);
            
            % histograms
            hist_fig = figure;
            histogram_figure(tst_brn_idx, is_runs,extra_str, ka_type,rank,batches);
            savefig(hist_fig,[image_dir,brain_base,'_hist.fig']);
            print([image_dir,brain_base,'_hist.png'],'-dpng');
            close(hist_fig);
            
            
            
            % make main figure
            figure(fmain);
            main_figure(tst_brn_idx, is_runs, ka_type, rank, batches,ha((bi-1)*6 + (1:6)),extra_str);
        end
        
        savefig(fmain,[image_dir,basefilename,'_main.fig']);
        print([image_dir,basefilename,'_main.png'],'-dpng');
    end
end

