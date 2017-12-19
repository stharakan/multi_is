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
                case 'near_tumor'
                    idx = obj.SelectNearTumor(brain,ppb);
            end
        end
        
    end
    
end

