#!/bin/bash
#SBATCH -J s2.save_brain_results # Job name
#SBATCH -o s2.save_brain_results.o # Name of stdout output file
#SBATCH -e s2.save_brain_results.e # Name of stderr error file
##SBATCH -J s2.all.OneShot4096 # Job name
##SBATCH -o s2.all.OneShot4096.o # Name of stdout output file
##SBATCH -e s2.all.OneShot4096.e # Name of stderr error file
#SBATCH -p skx-dev #Queue name
#SBATCH -N 1 # Total # of nodes (now required)
#SBATCH -n 1 # Total # of mpi tasks
#SBATCH -t 0:20:00 # Run time (hh:mm:ss
#SBATCH --mail-user=sameer@oden.utexas.edu
#SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2019a
cd $MISDIR/matlab

#matlab -r "startup;build_klr_model; single_brain_run; quit"  
#matlab -r "startup;sample_klris_all_test(1000,'OneShot',4096) ; quit"  
matlab -r "startup;brain_dice_loop; quit"  
#matlab -r "startup;run_covariance_spectrum(50,'DiagNyst',4096,4) ; quit" 
#matlab -r "test_grad_dummy(logspace(-1,2,10),[0.25 0.2 0.15 0.1],1); quit"  
#matlab -r "test_grad_smoothdummy(logspace(-1,2,10),[0.35 0.4 0.45 0.5],0); quit"  

