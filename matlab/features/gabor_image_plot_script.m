% Add path to other code
addpath(['./../general/']);
SetPath;
SetVariablesTACC;
disp('Set path and variables')

% Location of brains + output
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
out_dir = [getenv('SCRATCH'),'/gabor_figs/'];
mkdir out_dir

% gabor preferences 
wvs = 5; % goes to 2^wvs, number of gabor filts to check
bw = 16; % 1/2 patch width
angle = 0;
slices = [50,60,70,80];

% figure
buf = 0.01; % on a scale of 0 - 1
ppos = [0 0 6 9];
punits = 'inches';

% brain dir stuff
brncell = GetBrnList(brn_dir);
brncell = brncell(1:20);
disp('Got brain list')

% Initialize gaborfilter array
for gi = 1:wvs
    wv = 2^gi;
    gaborfilts(gi) = gabor(wv,angle,'SpatialFrequencyBandwidth',...
        GetSFBFromOthers(wv,bw),'SpatialAspectRatio',1.0);
end

% loop over brain
for bi = 1:length(brncell);
	% pick out brain
    brnname = brncell{bi};
	brnname = strtrim(brnname);
	disp(['Computing brain ',num2str(bi),' of ', num2str(length(brncell))]);
	disp(['Brain name: ',brnname]);
    
    % get figure
    figh = PlotGaborT1ceBrain(brn_dir,brnname,gaborfilts,buf,slices);
    
    % save figure
    figh.PaperUnits = punits;
    figh.PaperPosition = ppos;
    print([outdir,brnname,'.gaborslices'],'-dpng','-r0')
end

