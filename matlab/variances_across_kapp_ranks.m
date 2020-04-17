function [] = variances_across_kapp_ranks(tumor_idx)
brain_numbers = 1:6;
data_locations;
% for local testing
brain_numbers = [1];
ka_types = {'EnsNyst'};
ka_type_paper = {'ENS'};

ranks = [128, 512];
% ka_types = {'OneShot','DiagNyst','EnsNyst'};
%ka_type_paper = {'NYST','DIAG','ENS'};
% ranks = [128,512,4096];



for brain_number = brain_numbers
    counter = 1;
    
    
    
    fmain = figure;
    ha = tight_subplot(length(ka_types),length(ranks),[.001,.001],[.001,.001],[.1,.001]);
    
    for ka_type = ka_types
        
        ka_type = ka_type{1};
        batches = 4;
        if strcmp(ka_type,'OneShot')
            batches = 1;
        end
        
        for rank = ranks
            base_filename = generate_is_results_filename(brain_number,1000,ka_type,rank,batches);
            fname = [results_dir,base_filename,'.mat'];
            if exist(fname,'file')
                load(fname,'is_probs','brain_name','seg','max_tumor_idx') % get
                fprintf('loaded %s\n',fname);
            else
                fprintf('Could not find %s, exiting..\n',results_filename);
                return
            end
            
            
            % load t2
            brn = BrainReader(bdir,brain_name);
            fl = brn.ReadFlair();
            fl = fl(:,:,max_tumor_idx);
            nzidx = fl ~= 0;
            
            % get variances
            is_vars = var(is_probs,[],3);
            is_vars = reshape(is_vars, size(seg,1),size(seg,2),size(is_vars,2));
            is_vars( repmat(~nzidx,1,1,size(is_vars,3)) ) = min(is_vars(:));
            is_probs = reshape(is_probs,size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));
            is_probs = mean(is_probs,4);
            
            if tumor_idx
                tumor_var = is_vars(:,:,tumor_idx);
                is_probs = is_probs(:,:,tumor_idx);
            else
                tumor_var = sum(is_vars(:,:,2:end),3);
                is_probs = sum(is_probs(:,:,2:end),3);
            end
            tumor_var = max(tumor_var(:)) - tumor_var;
            
            % get tumor box
            [rows,cols] = getTumorBox(fl,0);
            tumor_var = tumor_var(rows,cols);
            is_probs = is_probs(rows,cols);
            
            % plot
            axes( ha(counter));
            h = imshow(tumor_var, []);
            alpha = 0.25;
            mask = ones(size(tumor_var));
            tol = 0.2;
            mask(is_probs < 0.2) = alpha;
            set(h, 'AlphaData', mask);
            
            counter = counter + 1;
        end
        
    end
    
    for ri = 1:length(ranks)
        axes(ha(ri));
        rank = ranks(ri);
        title(['Rank ',num2str(rank)],'FontSize',16)
    end
    
    for ki = 1:length(ka_types)
        axes(ha( (ki-1)*length(ranks) + 1))
        ka_type = ka_type_paper{ki};
        ylabel([ka_type],'FontSize',16,'FontWeight','bold')
    end
    
    
    % save fig
%     savefig(fmain,[image_dir,'b', num2str(brain_number),'_t',...
%         num2str(tumor_idx),'_variances.fig']);
%     print([image_dir,'b', num2str(brain_number),'_t',num2str(tumor_idx),...
%         '_variances.png'],'-dpng');
end