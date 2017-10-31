#!/bin/bash
#SBATCH -J compute            # job name
#SBATCH -o pearson.err        # output and error file name (%j expands to jobID)
#SBATCH -N 1                # number of nodes requested
#SBATCH -n 2               # total number of mpi tasks requested
#SBATCH -p largemem512GB      # queue (partition) -- normal, development, etc.
##SBATCH -p normal      # queue (partition) -- normal, development, etc.
#SBATCH -t 12:00:00         # run time (hh:mm:ss) - 1.5 hours



## Slurm email notifications are now working on Lonestar 5 
##SBATCH --mail-user=username@tacc.utexas.edu
##SBATCH --mail-type=begin   # email me when the job starts
##SBATCH --mail-type=end     # email me when the job finishes

module load python
module load matlab

cd $MISDIR/matlab/feature_selection

#python lgbm_model.py
matlab -r "pearson_scores; quit"
