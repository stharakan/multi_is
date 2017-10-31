% Add path to other code
%addpath(['./../general/']);
%SetPath;
%SetVariablesTACC;
%disp('Set path and variables')

% Location of brains + output
brn_dir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
out_dir = [getenv('SCRATCH'),'/gabor_figs/'];

% gabor preferences 
wvs = 5; % goes to 2^wvs, number of gabor filts to check
bws = [2 4 8 ]; % 1/2 patch width
angle = 0;
slices = [60,70,80,90];

% figure
buf = 0.01; % on a scale of 0 - 1
ppos = [0 0 6 9];
punits = 'inches';

% brain dir stuff
brncell = GetBrnList(brn_dir);
brncell = brncell(1:25);
disp('Got brain list')

for bw = bws
fprintf('processing bw %d ..\n',bw);

% Initialize gaborfilter array
for gi = 1:wvs
    wv = 2^gi;
    if wv < (bw * pi / sqrt(log(2)/2 ) )
	gaborfilts(gi) = gabor(wv,angle,'SpatialFrequencyBandwidth',...
      	    GetSFBFromOthers(wv,bw),'SpatialAspectRatio',1.0);
    end

end


% loop over brain
for bi = 1:length(brncell);
	% pick out brain
    brnname = brncell{bi};
    brnname = strtrim(brnname);

	if strcmp(brnname, 'Brats17_2013_10_1')
		disp(['Skipping brain: ',brnname]);
		continue;
else
	disp(['Computing brain ',num2str(bi),' of ', num2str(length(brncell))]);
	disp(['Brain name: ',brnname]);
 end
    
    
    % get figure
    figh = PlotGaborT1ceBrain(brn_dir,brnname,gaborfilts,buf,slices);
    
    % save figure
    figh.PaperUnits = punits;
    figh.PaperPosition = ppos;
    print([out_dir,brnname,'.gaborslices.bw.',num2str(bw)],'-dpdf')
end
end
