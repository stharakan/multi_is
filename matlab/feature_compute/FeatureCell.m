function [fcell] = FeatureCell(feature_type,psize)
%FEATURECELL produces a feature cell for a particular feature type/ psize.
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


