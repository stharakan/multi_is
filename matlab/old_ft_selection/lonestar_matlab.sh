#!/bin/bash
##SBATCH -J askitreg                # job name
##SBATCH -o askitreg.err        # output and error file name (%j expands to jobID)
##SBATCH -J regknn33.b15.d30                 # job name
##SBATCH -o regknn33.b15.d30.err        # output and error file name (%j expands to jobID)
#SBATCH -J bla.reg            # job name
#SBATCH -o bla.reg.err        # output and error file name (%j expands to jobID)
#SBATCH -N 1                # number of nodes requested
#SBATCH -n 2               # total number of mpi tasks requested
##SBATCH -p largemem512GB      # queue (partition) -- normal, development, etc.
##SBATCH -p skx-dev      # queue (partition) -- normal, development, etc.
#SBATCH -p skx-normal      # queue (partition) -- normal, development, etc.
#SBATCH -t 3:30:00         # run time (hh:mm:ss) - 2.5 hours



## Slurm email notifications are now working on Lonestar 5 
##SBATCH --mail-user=username@tacc.utexas.edu
##SBATCH --mail-type=begin   # email me when the job starts
##SBATCH --mail-type=end     # email me when the job finishes

module load python
module load matlab/2017a

cd $MISDIR/matlab/feature_selection

#python lgbm_model.py
#matlab -r "gabor_only_stats; quit"
#matlab -r "process_askitreg_output; quit"
#matlab -r "KNNRegressionLoop_func(33,30,[16 32 128 255]); quit"
#matlab -r "save_truncated_features; quit"
#matlab -r "svm_rfe_func(100,.1,17,120,0.01); quit"
#matlab -r "svm_rfe_func(100,.1,9,96,0.000001); quit"
matlab -r "cv_svmreg; quit"
