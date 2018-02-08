classdef BrainPointList
    %BRAINPOINTLIST assembles a list of points for each brain in a given
    %cell array. By specifying the point picking method.
    
    properties
        pt_inds
        pts_per_brain
        brain_cell
        brain_dir
        num_brains
        pt_selector
        tot_points
        brn_markers
    end
    
    methods
        % constructor
        function obj = BrainPointList(bdir,bcell,pt_s,sdir)
            if isempty(bcell)
                bcell = GetBrnList(bdir);
            end

            if nargin < 3, sdir = []; end
            
            % set vars
            bb = length(bcell);
            obj.num_brains = bb;
            obj.pt_inds = cell(bb,1);
            obj.brain_cell = bcell(:);
            obj.brain_dir = bdir;
            obj.pts_per_brain = pt_s.ppb;
            obj.pt_selector = pt_s;
            tp = 0;
            bm = zeros(bb+1,1);
            bm(1) = 0;
            
            if nargin > 3 & BrainPointList.CheckForList(sdir,pt_s,bb)
                obj = BrainPointList.LoadList(sdir,pt_s,bb);
                return
            end
            
            for ii = 1:bb
                %cur_brain = BrainReader(bdir,bcell{ii});
                cur_brain = obj.MakeBrain(ii);
                cur_idx = obj.pt_selector.SelectPoints(cur_brain);
                obj.pt_inds{ii} = cur_idx;
                tp = tp + length(cur_idx);
                bm(ii+1) = tp;
            end
            obj.tot_points = tp;
            obj.brn_markers = bm;
            
            if nargin > 3
                obj.SaveList(sdir);
            end
        end
        
        % save to file
        function [] = SaveList(obj,sdir)
            sfile = obj.MakeFileName();
            save([sdir,sfile],'obj');
        end
        
        % Standardize file name creation
        function sfile = MakeFileName(obj)
            sfile = ['list.',obj.pt_selector.PrintString(),'.bb.',...
                num2str(obj.num_brains),'.mat'];
        end
        
        % Make brain bi
        function brain = MakeBrain(obj,bi)
            brain = BrainReader(obj.brain_dir,obj.brain_cell{bi});
        end
        
        % Find index of bi within larger index
        function idx = WithinTotalIdx(obj,bi)
            idx = (obj.brn_markers(bi) + 1):obj.brn_markers(bi+1);
        end
        
        % ppvec file name maker
        function sfile = MakePPvecFile(obj,psize,target)
            sfile = ['ppv.',obj.pt_selector.PrintString(),'.bb.',...
                num2str(obj.num_brains),'.ps.',num2str(psize), ...
                '.t.', num2str(target),'.bin'];
        end
        
        % ppvec file name maker for figs
        function sfile = MakePPvecAnalyzeFile(obj,psize,target)
            sfile = ['figs.',obj.pt_selector.PrintString(),'.bb.',...
                num2str(obj.num_brains),'.ps.',num2str(psize), ...
                '.t.', num2str(target),'.fig'];
        end
        
        % file name maker for feature data
        function [sfile] = MakeFeatureDataString(obj,ftype,psize)
            str = [ftype,'.ps.',num2str(psize),'.',...
                obj.pt_selector.PrintString(), ...
                '.nn.',num2str(obj.tot_points)];
            
            sfile = ['data.',str,'.bin'];
        end
        
        % file name maker for feature ranks
        function [sfile] = MakeFRString(obj,frstr,ftype,psize,target,params)
            str = ['.',ftype,'.ps.',num2str(psize),'.',...
                obj.pt_selector.PrintString(), ...
                '.nn.',num2str(obj.tot_points),'.t.',num2str(target),...
                PrintRFEParams(params)];
            sfile = [frstr,str,'.bin'];
            
        end
        
        % return a blist based on an index of brains
        function blist = BlistSubsetFromIdx(obj,idx)
            nb = length(idx);
            
            % --- things to set ----
            % 1 pt_inds
            % 2 pts_per_brain
            % 3 brain_cell
            % 4 brain_dir
            % 5 num_brains
            % 6 pt_selector
            % 7 tot_points
            % 8 brn_markers
            
            blist = obj; % pt_selector, brain_dir, pts_per_brain
            blist.num_brains = nb; % num_brains
            blist.pt_inds = obj.pt_inds(idx); % pt_inds
            blist.brain_cell = obj.brain_cell(idx); % brain_cell
            idx_lengths = cellfun('length',blist.pt_inds);
            blist.tot_points = sum(idx_lengths); % tot_points
            blist.brn_markers = zeros(nb + 1,1);
            blist.brn_markers(2:end) = cumsum(idx_lengths); % brn_markers
        end

        function [] = PrintListInfo(obj)
            fprintf([' BrainPointList stats\n Num_brains: %d\n ',...
            'pt_selector: %s\n total pts: %d\n'],obj.num_brains, ...
            obj.pt_selector.PrintString(),obj.tot_points);
        end

        
        [ fmat,fcell ] = PatchGaborFeatures( blist,psize )
        
        [ fmat,fcell ] = PatchStatsFeatures( blist,psize )
        
        [ fmat,fcell ] = PatchGStatsFeatures( blist,psize )
        
        [ trn_blist,tst_blist ] = Split( obj,perc )
        
        [ blist_out ] = RoundDown( blist,pof10 )
        
        [ trn,tst ] = SplitAndRound( blist,sperc,pof10 )
    end
    
    methods (Static)
        function [fcell] = FeatureCell(feature_type,psize)
            switch feature_type
                case 'patchstats'
                    %fcell = {'mean','max','median','std','l2','l1'};
                    fcell = {'mean','std','median','l2'};
                    fcell = strcat('p.',num2str(psize),'.',fcell(:)');
                case 'patchgabor'
                    bw = (psize - 1)/2;
                    [~,fcell] = InitializeGaborBank(bw);
                case 'patchgstats'
                    bw = (psize - 1)/2;
                    [~,gcell] = InitializeGaborBank(bw,0);
                    scell = {'mean','max','median','std','l2','l1'};
                    ss = length(scell);
                    gg = length(gcell);
                    
                    scell = repmat(scell(:),1,gg);
                    gcell = repmat(gcell(:)',ss,1);
                    
                    fcell = strcat(gcell(:)','.',scell(:)');
                otherwise
                    error('feature_type not recognized');
            end
            
            % add in modalities
            ddcur = length(fcell);
            mods = repmat({'fl','t1','t1c','t2'},ddcur,1);
            gcell = repmat(fcell(:),1,4);
            fcell = strcat(mods(:)','.',gcell(:)');
            
        end
        
        function [str] = MakeFileNameStatic(ps,nb)
            str = ['list.',ps.PrintString(),'.bb.',...
                num2str(nb),'.mat'];
        end

        function [blist] = LoadList(sdir,ps,nb)
            % add in modalities
            sfile = BrainPointList.MakeFileNameStatic(ps,nb);
            mat = load([sdir,sfile]);
            blist = mat.obj;
        end
        
        function [flag] = CheckForList(sdir,ps,nb)
            % add in modalities
            sfile = BrainPointList.MakeFileNameStatic(ps,nb);
            flag = exist([sdir,sfile],'file');
        end
    end
end

