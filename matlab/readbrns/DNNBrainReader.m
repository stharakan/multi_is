classdef DNNBrainReader < BrainReader
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bdir_dnn_tissue
        bdir_dnn_tumor
    end
    
    methods
        function obj = DNNBrainReader(b_dir,b_name, b_dir_dnn_tissue, b_dir_dnn_tumor)
            obj@BrainReader(b_dir,b_name);
            obj.bdir_dnn_tissue = b_dir_dnn_tissue;
            obj.bdir_dnn_tumor = b_dir_dnn_tumor;
        end
        
        function dataset = read_brain_hd5(obj,filename)
            hinfo = hdf5info(filename);
            dataset = hdf5read(hinfo.GroupHierarchy.Datasets(1));
            dataset = permute(dataset,[3,2,1,4]); % switches x,y to match nii.gz and puts slices in 3rd idx
        end
        
        function im = read_brain_nii(obj,filename)
            nifti = load_untouch_nii(filename);
            im = nifti.img;
        end
        
        function im = ReadTumorProbs(obj)
            fbase = [obj.bdir_dnn_tumor,obj.bname];
            im = obj.read_brain_hd5([fbase,'_prob.h5']);
        end
        
        function im = ReadTumorFeatures(obj)
            fbase = [obj.bdir_dnn_tumor,obj.bname];
            im = obj.read_brain_hd5([fbase,'_feature.h5']);
        end
        
        function im = ReadTumorSeg(obj)
            fbase = [obj.bdir_dnn_tumor,obj.bname];
            im = obj.read_brain_nii([fbase,'_seg.nii.gz']);
        end
        
        function im = ReadTissueProbs(obj)
            fbase = [obj.bdir_dnn_tissue,obj.bname];
            im = obj.read_brain_hd5([fbase,'_prob.h5']);
        end
        
        function im = ReadTissueSeg(obj)
            fbase = [obj.bdir_dnn_tissue,obj.bname];
            im = obj.read_brain_nii([fbase,'_seg.nii.gz']);
        end
        
        function im = ReadTissueFeatures(obj)
            fbase = [obj.bdir_dnn_tissue,obj.bname];
            im = obj.read_brain_hd5([fbase,'_feature.h5']);
        end
        
        function feats = ReadTissueFeatures2D(obj)
            im = obj.ReadTissueFeatures();
            feats = reshape(im,[],16);
        end
        
        function feats = ReadTumorFeatures2D(obj)
            im = obj.ReadTumorFeatures();
            feats = reshape(im,[],16);
        end

    end
end

