import os
import numpy
import sys

#launcher_job_file = os.environ['BRATSREPO'] + '/matlab/mlmodels/python_job_file';
launcher_job_file = os.environ['BRATSREPO'] + '/matlab/features/matlab_job_file2';
job_file = open(launcher_job_file, 'w+');
nsections=60

for i in xrange(nsections):
    cmd = 'matlab -nodisplay -r "addpath( [getenv(\'BRATSREPO\'),\'/matlab/features\']); save_indiv_brain_features_func('+str(i+1)+','+str(nsections)+'); quit;"';
    #cmd = 'python '+os.environ['BRATSREPO']+'/matlab/mlmodels/segment_brain.py '+str(i)+' '+str(nsections); 
    cmd = cmd + '\n';
    job_file.write(cmd);

    

job_file.close();

