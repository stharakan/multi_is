#!/bin/bash
#
# Simple SLURM script for submitting multiple serial
# jobs (e.g. parametric studies) using a script wrapper
# to launch the jobs.
#
# To use, build the launcher executable and your
# serial application(s) and place them in your WORKDIR
# directory.  Then, edit the CONTROL_FILE to specify 
# each executable per process.
#-------------------------------------------------------
#-------------------------------------------------------
# 
#         <------ Setup Parameters ------>
#
#SBATCH -J trnhggP
#SBATCH -N 2 
#SBATCH -n 8
##SBATCH -p normal 
#SBATCH -p largemem512GB
#SBATCH --reservation BRATS_Challenge 
#SBATCH -o trnhggProbs.o%j
#SBATCH -t 12:00:00

################ TODO#######################
# JOB_NAME = change it according to your job
# N = number of nodes requested
# n = number of cores per node requested
# wall clock time
###########################################

# python and hwloc required for launcher
module load python
module load hwloc

# TODO load other required modules here
module load matlab

# Set enviroment vaiables for Launcher
export LAUNCHER_DIR=${BRATSDIR}/external/launcher 		# Do not change
export LAUNCHER_PLUGIN_DIR=${LAUNCHER_DIR}/plugins 		# Do not change
export LAUNCHER_NHOSTS=2           				# TODO run on 2 cluster nodes    
export LAUNCHER_PPN=4              				# TODO number of processes per node, max limit for Lonestar=24, Maverick=20
# Number of simulaneous processes = PPN * NHOSTS
export LAUNCHER_SCHED=interleaved   				# don't touch
export LAUNCHER_WORKDIR=${SCRATCH}  			# TODO modify to the desired directory output
export LAUNCHER_RMI=SLURM 					# Don't touch
export LAUNCHER_BIND=1 						# Don't touch 
# Set path to job_file listing commands and no trailing empty lines. every line should correspond to a serial job. 
export LAUNCHER_JOB_FILE=${BRATSREPO}/matlab/mlmodels/matlab_job_file # TODO
#export LAUNCHER_JOB_FILE=${BRATSREPO}/matlab/mlmodels/python_job_file # TODO
$LAUNCHER_DIR/paramrun 						# Run Launcher

