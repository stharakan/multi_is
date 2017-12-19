classdef BrainReader
    %BrainReader is a class to read brain files
    
    properties
        bdir
        bname
    end
    
    methods
        % Constructor
        function obj = BrainReader(b_dir,b_name)
            obj.bdir = b_dir;
            obj.bname = b_name;
        end
        
        % Reader files
        function im = ReadFlair(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_flair_normaff.nii.gz']);
            im = nifti.img;
        end
        
        function im = ReadT2(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_t2_normaff.nii.gz']);
            im = nifti.img;
        end
        
        function im = ReadT1(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_t1_normaff.nii.gz']);
            im = nifti.img;
        end
        
        function im = ReadT1ce(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_t1ce_normaff.nii.gz']);
            im = nifti.img;
        end
        
        function im = ReadSeg(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_seg_aff.nii.gz']);
    		im = nifti.img;
        end
        
        function [flair,t1,t1ce,t2] = ReadAllButSeg(obj)
            flair = obj.ReadFlair();
            t1 = obj.ReadT1();
            t1ce = obj.ReadT1ce();
            t2 = obj.ReadT2();
        end
        
        function [flair,t1,t1ce,t2,seg] = ReadAll(obj)
            flair = obj.ReadFlair();
            t1 = obj.ReadT1();
            t1ce = obj.ReadT1ce();
            t2 = obj.ReadT2();
            seg = obj.ReadSeg();
        end
        
    end
    
end

