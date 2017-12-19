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
	end

	methods
	% constructor
	function obj = BrainPointList(bdir,bcell,pt_s,ppb,sdir)
		bb = length(bcell);
		obj.num_brains = bb;
		obj.pt_inds = cell(bb,1);
		obj.brain_cell = bcell;
		obj.brain_dir = bdir;
		obj.pts_per_brain = ppb;
		obj.pt_selector = pt_s;

		if nargin > 4 & obj.CheckForList(sdir)
			obj = obj.LoadList(sdir);
			return
		end

		for ii = 1:bb
			cur_brain = BrainReader(bdir,bcell{ii});
			cur_idx = obj.pt_selector.SelectPoints(cur_brain,ppb);
			obj.pt_inds{ii} = cur_idx;
		end
	end

	% save to file
	function [] = SaveList(obj,sdir)
		sfile = obj.MakeFileName();
		save([sdir,sfile],'obj');
	end
	
	% Load file
	function obj2 = LoadList(sdir)
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


	end
	
end

