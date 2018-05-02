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
        
        % Reader funcs
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
        
        function P = ReadProbs(obj,pdir,pstr)
            fname = [pdir,obj.MakeDataString(pstr,'nii.gz')];
            nifti = load_untouch_nii(fname);
            P = nifti.img;
        end
        
        % writing funcs
        function st = MakeDataString(obj,prefix,suffix)
            st = [prefix,'.',obj.bname,'.',suffix];
        end
        
        function [] = SaveProbs(obj,P,pdir,pstr)
            fname = [pdir,obj.MakeDataString(pstr,'nii.gz')];
            nifti = make_nii(P);
            nifti.untouch = 1;
            nifti.hdr = obj.GetSingleHdr();
            save_untouch_nii(nifti,fname);
        end
            
        function hdr = GetSingleHdr(obj)
            fbase = [obj.bdir,obj.bname,'/',obj.bname];
            nifti = load_untouch_nii([fbase,'_flair_normaff.nii.gz']);
            hdr = nifti.hdr;
        end
            
        function nvox  = GetTotalVoxels(obj)
            nvox = 240*240*155;
        end
        
    end
    
end

