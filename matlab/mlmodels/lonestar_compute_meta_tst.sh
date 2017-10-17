#!/bin/bash
#SBATCH -J tst-lgbm.out            # job name
#SBATCH -o tst-lgbm.err        # output and error file name (%j expands to jobID)
#SBATCH -N 1                # number of nodes requested
#SBATCH -n 20               # total number of mpi tasks requested
#SBATCH -p largemem512GB      # queue (partition) -- normal, development, etc.
##SBATCH -p normal      # queue (partition) -- normal, development, etc.
#SBATCH -t 04:00:00         # run time (hh:mm:ss) - 1.5 hours



## Slurm email notifications are now working on Lonestar 5 
##SBATCH --mail-user=username@tacc.utexas.edu
##SBATCH --mail-type=begin   # email me when the job starts
##SBATCH --mail-type=end     # email me when the job finishes

module load python
module load matlab

cd $BRATSREPO/matlab/mlmodels

#python lgbm_model.py
matlab -r "meta_preprocess_func('tst',1,1,1); quit"
python segment_brain.py 1 0 1 
matlab -r "meta_postprocess_func('tst',1,1,1); quit"
