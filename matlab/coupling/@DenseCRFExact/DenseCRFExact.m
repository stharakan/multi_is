classdef DenseCRFExact
    %Contains the crf structure, as well as functions to compute/update
    %pairwise messages and weights. Can also run Newton solver and compute
    %various derivatives
    
    properties
        nn % number of pixels in image
        cc % number of classes
        K_app
        app_sum
        h_spa % spatial filter
        M % label compatability matrix
        unary % stores unary probabilities (nn x cc)
        mods % 3rd dimension of image
        imsz % vector of imsize
        weight % weight factor for message passing
        app_weight % weight factor for appearance kernel
    end
    
    methods
        % constructor 
        function obj = DenseCRFExact(im,bws,mu,un,ww)
            % unary, basic params
            [obj.nn,obj.cc] = size(un);
            obj.unary = ResetProbabilityZeros(un);
            
            % label comp
            if isempty(mu)
                obj.M = 1- eye(obj.cc);
            else
                obj.M = mu;
            end

            if nargin < 5
                obj.weight = 1;
            else
                obj.weight = ww;
            end

            % image 
            sz = size(im);
            obj.imsz = sz(1:2);
            if length(sz) == 2
                obj.mods = 1;
            else
                obj.mods = sz(3);
            end
            
            % appearance kernel
            app_bws = [ones(2,1).* bws(1); ones(obj.mods,1).*bws(2)];
            [xx,yy] = meshgrid(1:sz(1),1:sz(2));
            imfeats = reshape(im,sz(1)*sz(2),obj.mods);
            fmat = [xx(:),yy(:),imfeats];
            obj.K_app = gaussiankerneldiag(fmat,fmat,app_bws);
            obj.K_app(1:(obj.nn+1):end) = 0;
            obj.app_sum = sum(obj.K_app,2);
            obj.app_weight = 1;
            
            
            % spatial kernel
            spbw = bws(3); 
            bwsz = spbw*5;
            obj.h_spa = fspecial('gaussian',[bwsz bwsz],spbw);
        end
        
        % apply app filters
        function m_app = ApplyAppKernel(obj,v)
            m_app = obj.K_app * v;
            m_app = bsxfun(@rdivide,m_app,obj.app_sum);
        end
        
        % apply spatial filter
        function m_spa = ApplySpaKernel(obj,v)
            vim = reshape(v,obj.imsz(1),obj.imsz(2),obj.cc);
            m_spa = imfilter(vim,obj.h_spa,'same');
            m_spa = reshape(m_spa,obj.imsz(1) * obj.imsz(2),[]);
            m_spa = m_spa - v;
        end
        
        % pairwise message
        function m = PairwiseMessage(obj,Qin)
            % appearance kernel
            m_app = obj.ApplyAppKernel(Qin);
            
            % spatial kernel
            m_spa = obj.ApplySpaKernel(Qin);
            
            % combine messages
            m = m_spa + obj.app_weight .* m_app;
            %m = m_spa;
            %m = m_app;
            m = (m * obj.M).* obj.weight;
        end
        
        % Gradient only
        function g = Gradient(obj,Qin)
            Qin = NormalizeClassProbabilities(Qin);
            g = -log(obj.unary./Qin) + obj.PairwiseMessage(Qin) + 1;
        end
         
        % Hessian only
        function vout = ApplyHessian(obj,Qin,vin)
            vh1 = obj.PairwiseMessage(vin);
            vh2 = vin./Qin;
            vout = vh1 + vh2;
        end
        
        % Function val only
        function fval = FunctionEval(obj,Qin)
            Qin = NormalizeClassProbabilities(Qin);
            lg = log(Qin);
            m = obj.PairwiseMessage(Qin);
            ff = (-log(obj.unary) + m./2 + lg).*Qin;
            fval = sum(ff(:));
        end
        
        % fval + grad
        function [fval,g] = FunctionAndGradient(obj,Qin)
            Qin = NormalizeClassProbabilities(Qin);
            m = obj.PairwiseMessage(Qin);
            
            % gradient
            %lg = double(log(Qin));
            %obj_sum = double(m)./2 +  log(  double(Qin)./double(obj.unary) ) ;
            obj_sum = double(m) +  log(  double(Qin) ) - log(double(obj.unary) ) ;
            %obj_sum = log(  double(Qin) ) - log( double(obj.unary) ) ;
            g = obj_sum + 1;
            g = double(g);
            
            % fval
            obj_sum = obj_sum - double(m)./2;
            ff = obj_sum.*Qin;
            %ff = double(obj.unary).*Qin;
            fval = sum(ff(:));
            fval = double(fval);
        end
        
    end
    
end

