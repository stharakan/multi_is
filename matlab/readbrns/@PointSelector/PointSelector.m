classdef PointSelector
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stype
        ppb
        psize
    end
    
    methods
        % constructor
        function obj = PointSelector(st,ppb,psize)
            obj.stype = st;
            if nargin < 2 
                obj.ppb = 0;
            else
                obj.ppb = ppb;
            end
            if nargin < 3
                obj.psize = 0;
            else
                obj.psize = psize;
            end
        end
        
        % Point selector, add cases as necessary
        function idx = SelectPoints(obj,brain)
            switch obj.stype
                case 'all'
                    idx = obj.SelectRandom(brain); %TODO
                case 'random'
                    idx = obj.SelectRandom(brain);
                case 'neartumor'
                    idx = obj.SelectNearTumor(brain);
                case 'nearedema'
                    idx = obj.SelectNearEdema(brain);
                case 'edemanormal'
                    idx = obj.SelectEdemaNormal(brain);
                case 'edemadist'
                    idx = obj.SelectEdemaDistribution(brain);
            end
        end
        
        % outputs a probability map for a given brain
        function pmap = PointProbabilityMap(obj,brain)
            switch obj.stype
                case 'all'
                    pmap = obj.MapRandom(brain); %TODO
                case 'random'
                    pmap = obj.MapRandom(brain);%TODO
                case 'neartumor'
                    pmap = obj.MapNearTumor(brain);%TODO
                case 'nearedema'
                    pmap = obj.MapNearEdema(brain);%TODO
                case 'edemanormal'
                    pmap = obj.MapEdemaNormal(brain);%TODO
                case 'edemadist'
                    pmap = obj.MapEdemaDistribution(brain);%TODO
            end
            
        end
        
        function pstr = PrintString(obj)
            
            if obj.psize
                pstr = [obj.stype,'.ppb.',num2str(obj.ppb),'.ps.',num2str(obj.psize)];
            else
                pstr = [obj.stype,'.ppb.',num2str(obj.ppb)];
            end
                
        end
            
        
        [ idx ] = SelectEdemaNormal( obj,brain );
        [ idx ] = SelectRandom( obj,brain );
        [ idx ] = SelectNearTumor( obj,brain );
        [ idx ] = SelectNearEdema( obj,brain );
        [ idx ] = SelectEdemaDistribution( obj,brain );
        [ pmap ] = MapEdemaDistribution( ps,brain );
        [ pmap ] = MapNearEdema( ps,brain )
    end
    
end

