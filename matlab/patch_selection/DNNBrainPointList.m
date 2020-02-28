classdef DNNBrainPointList < BrainPointList
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bdir_dnn_tissue
        bdir_dnn_tumor
    end
    
    methods
        function obj = DNNBrainPointList(bdir,bcell,pt_s,bdir_dnn_tissue,bdir_dnn_tumor,sdir)
            obj@BrainPointList(bdir,bcell,pt_s,sdir);
            obj.bdir_dnn_tissue = bdir_dnn_tissue;
            obj.bdir_dnn_tumor  = bdir_dnn_tumor;
        end
        
        function brain = MakeBrain(obj,bi)
            if isprop(obj,'bdir_dnn_tissue')
                brain = DNNBrainReader(obj.brain_dir,obj.brain_cell{bi},obj.bdir_dnn_tissue,obj.bdir_dnn_tumor);
            else
                brain = MakeBrain@BrainPointList(obj,bi);
            end
        end
        
    end
    
     methods (Static)
        function [fcell] = FeatureCell(feature_type)
            switch feature_type
                case 'tissue'
                    fcell = cellstr( strsplit( num2str(1:16) ) );
                    fcell = strcat('tissue',fcell);
                case 'tumor'
                    fcell = cellstr( strsplit( num2str(1:16) ) );
                    fcell = strcat('tumor',fcell);
                case 'all'
                    fcell1 = DNNBrainPointList.FeatureCell('tissue');
                    fcell2 = DNNBrainPointList.FeatureCell('tumor');
                    fcell = [fcell1,fcell2];
                otherwise
                    error('feature_type not recognized');
            end
            
        end
     end
end

