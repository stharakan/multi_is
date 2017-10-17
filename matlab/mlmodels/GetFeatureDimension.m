function dd = GetFeatureDimension(feature_type)


switch feature_type
    case 'gabor3d'
        dd = 864;
    case 'gabor'
        dd = 288;
    case 'int'
        dd = 4;
    case 'diff'
        dd = 6;
    case 'window'
        dd = 16;
    case 'gabor3d'
        dd = 288*3;
    otherwise
        error('features not recognized');
end



end
