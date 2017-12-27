classdef PointSelector
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stype
    end
    
    methods
        % constructor
        function obj = PointSelector(st)
            obj.stype = st;
        end
        
        % Point selector, add cases as necessary
        function idx = SelectPoints(obj,brain,ppb)
            switch obj.stype
                case 'all'
                    idx = obj.SelectRandom(brain,0);
                case 'random'
                    idx = obj.SelectRandom(brain,ppb);
                case 'neartumor'
                    idx = obj.SelectNearTumor(brain,ppb);
                case 'edemanormal'
                    idx = obj.SelectEdemaNormal(brain,ppb);
            end
        end
        
        [ idx ] = SelectEdemaNormal( obj,brain,ppb )
                
    end
    
end

