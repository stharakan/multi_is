#!/bin/bash
#SBATCH -J ls5.all.DiagNyst512 # Job name
#SBATCH -o ls5.all.DiagNyst512.o # Name of stdout output file
#SBATCH -e ls5.all.DiagNyst512.e # Name of stderr error file
#SBATCH -p largemem512GB # Queue name
#SBATCH -N 1 # Total # of nodes (now required)
#SBATCH -n 1 # Total # of mpi tasks
#SBATCH -t 10:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@oden.utexas.edu
#SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2019a
cd $MISDIR/matlab

#matlab -r "startup;build_klr('DiagNyst',512,2);test_brain_max_tumor_probs(1,100,'DiagNyst',512,2) ; quit"  
#matlab -r "startup;build_klr('DiagNyst',512,4);test_brain_max_tumor_probs(1,100,'DiagNyst',512,4) ; quit"  
#matlab -r "startup;build_klr('DiagNyst',512,4) ; quit"  
#matlab -r "startup;test_brain_max_tumor_probs(1,1000,'EnsNyst',512,4) ; quit"  
#matlab -r "startup;create_dnn_data; quit"  
matlab -r "startup;sample_klris_all_test(1000,'DiagNyst',512,4) ; quit"  

