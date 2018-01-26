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
            
            if nargin > 4 & obj.CheckForList(sdir)
                obj = obj.LoadList(sdir);
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
            
            if nargin > 4
                obj.SaveList(sdir);
            end
        end
        
        % save to file
        function [] = SaveList(obj,sdir)
            sfile = obj.MakeFileName();
            save([sdir,sfile],'obj');
        end
        
        % Load file
        function obj2 = LoadList(obj,sdir)
            sfile = obj.MakeFileName();
            bla = load([sdir,sfile]);
            obj2 = bla.obj;
        end
        
        % check if file exists
        function cflag = CheckForList(obj,sdir)
            sfile = obj.MakeFileName();
            cflag = exist([sdir,sfile],'file');
        end
        
        % Standardize file name creation
        function sfile = MakeFileName(obj)
            sfile = ['list.',obj.pt_selector.PrintString(),'.bb.',...
                num2str(obj.num_brains),'.nn.',...
                num2str(obj.tot_points),'.mat'];
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
            sfile = ['ppv.',obj.pt_selector.PrintString(),'.ppb.',...
                num2str(obj.pts_per_brain),'.bb.',...
                num2str(obj.num_brains),'.ps.',num2str(psize), ...
                '.t.', num2str(target),'.bin'];
        end
        
        % ppvec file name maker for figs
        function sfile = MakePPvecAnalyzeFile(obj,psize,target)
            sfile = ['figs.',obj.pt_selector.PrintString(),'.ppb.',...
                num2str(obj.pts_per_brain),'.bb.',...
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
                PrintParams(params)];
            sfile = [frstr,str,'.bin'];
                
        end
        
        [ fmat,fcell ] = PatchGaborFeatures( blist,psize )
        
        [ fmat,fcell ] = PatchStatsFeatures( blist,psize )
        
        [ fmat,fcell ] = PatchGStatsFeatures( blist,psize )
        
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
        
    end
end

