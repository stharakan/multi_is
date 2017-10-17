function ResampleNii(input_file,template_file,output_file,method)
%function ResampleNii(input_file,template_file,output_file,method)
% 
% Uses MATLAB's imresize3() funciton to resample an NII image. 
%
% input_file  - nii.gz file to be resampled
% template_file - nii.gz file that defines the output header and target
%                 resolution
% outpute_file - name of outputfile
% method - interpolation method (optional). default is 'linear'; see
% imresize3() for more options
%
% Example:  ResampleNii( 'in.nii.gz',  'ref.nii.gz',  'in2ref.nii.gz');
%
% if input_file is empty, then ResampleNii process all the files in the
% current directory and saves the resampled files in a directory caled
% "ResampleNii_Output"



if nargin<4
    method = 'linear';
end

if isempty(input_file)
    files = dir('./*nii.gz');
    output_dir = 'ResampleNii_Output';
    system(['mkdir ', output_dir]);

    for jj=1:length(files)
        ResampleNii( files(jj).name, template_file, [output_dir, ...
                            '/', files(jj).name]);
    end
    return;
end

target_nii = load_untouch_nii( template_file );
target_resolution = size(target_nii.img);

input_nii = load_untouch_nii( input_file );
output_nii = target_nii;


% RESAMPLING TAKES PLACE HERE
output_nii.img = imresize3( input_nii.img, target_resolution, ...
                            method);


save_untouch_nii( output_nii, output_file );







                        






