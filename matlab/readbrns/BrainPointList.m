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
		function obj = BrainPointList(bdir,bcell,pt_s,ppb,sdir)
      if isempty(bcell)
				bcell = GetBrnList(bdir);
    	end
        
    	% set vars
      bb = length(bcell);
			obj.num_brains = bb;
			obj.pt_inds = cell(bb,1);
			obj.brain_cell = bcell(:);
			obj.brain_dir = bdir;
			obj.pts_per_brain = ppb;
			obj.pt_selector = pt_s;
			tp = 0;
			bm = zeros(bb+1,1);
			bm(1) = 1;

			if nargin > 4 & obj.CheckForList(sdir)
				obj = obj.LoadList(sdir);
				return
			end

			for ii = 1:bb
				%cur_brain = BrainReader(bdir,bcell{ii});
				cur_brain = obj.MakeBrain(ii);
				cur_idx = obj.pt_selector.SelectPoints(cur_brain,ppb);
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
			sfile = ['list.',obj.pt_selector.stype,'.ppb.',...
			num2str(obj.pts_per_brain),'.bb.',...
			num2str(obj.num_brains),'.mat'];
		end

		% Make brain bi
		function brain = MakeBrain(obj,bi)
			brain = BrainReader(obj.brain_dir,obj.brain_cell{bi});
		end

		% Find index of bi within larger index
		function idx = WithinTotalIdx(obj,bi)
			idx = obj.brn_markers(bi):obj.brn_markers(bi+1);		
		end
		
		function sfile = MakePPvecFile(obj,psize,target)
			sfile = ['ppv.',obj.pt_selector.stype,'.ppb.',...
			num2str(obj.pts_per_brain),'.bb.',...
			num2str(obj.num_brains),'.ps.',num2str(psize), ...
			'.t.', num2str(target),'.bin'];
		end
	end
	
end
