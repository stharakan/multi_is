#!/bin/bash
# Set defaults
BDIR=${BRATSDIR}/preprocessed/trainingdata/meanrenorm/;
PSSTR='random';
PSP1=2000;
PSIZE=5;
OUTDIR=${PRDIRSCRATCH}/
FTYPE=patchstats
TARGET=2;
STYPE=reg01;
FKEEP=10;
KCUT=8;
KK=512;
BW=0.7;

# Process command line
usage="$(basename "$0") [-h] [-?] [-b -d -s -o -p -q -f -k -c -w -t] -- run trn/tst list creation 

where:
  -h  Show this help text
  -?  Show this help text
  -b  Brain directory 
  -d  Output directory 
  -s  Point Selector type
  -o  target output: 0 -> WT, 2 -> ED, etc. 
  -p  Point selector param 1 
  -q  Patch size
  -f  Feature type
  -k  Number of features to retain
  -w  Bandwidth for askit kernel
  -c  Number of neighbors to cut
  -t  output sbatch file, don't run"

while getopts "h?b:d:s:o:p:q:f:k:w:c:n:tP:" opt; do
  case "$opt" in
    h|\?)
      echo "$usage"
      exit 0
      ;;
    b) BDIR=$OPTARG
      ;;
    d) OUTDIR=$OPTARG
      ;;
    s) PSSTR=$OPTARG
      ;;
    o) TARGET=$OPTARG
      ;;
    t) TEST=true
      ;;
    p) PSP1=$OPTARG
      ;;
    q) PSIZE=$OPTARG
      ;;
    f) FTYPE=$OPTARG
      ;;
    k) FKEEP=$OPTARG
      ;;
    w) BW=$OPTARG
      ;;
    c) KCUT=$OPTARG
      ;;
    n) KK=$OPTARG
      ;;
  esac
done

filen=ask.${BW}.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# find n_ref, trnfile, and knnfile
trnfile=$(ls ${OUTDIR}/knntrn.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${trnfile}
n_ref=${delims[-2]};
knnfile=${trnfile%.bin}.kk.${KCUT}.bin;
knnfile=${knnfile/knntrn/nntrnlist};
mm=256
id_rank=128
id_tol=0.00000001

ppvfile=$(ls ${OUTDIR}/ppv*${PSSTR}*${PSP1}*.${PSIZE}.*208.*${TARGET}*)
cmfilein=${ppvfile/ppv/trn.${FTYPE}.cm};
potfile=${ppvfile%.bin}.h.${BW}.pot
yyfile=${potfile/ppv/trn.${FTYPE}.yy};
onesfile=${potfile/ppv/trn.${FTYPE}.1s};
cmfile=${potfile/ppv/trn.${FTYPE}.cm};
rofile=${potfile/ppv/trn.${FTYPE}.ro};

# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 32 # Total # of nodes (now required)
#SBATCH -n 32 # Total # of mpi tasks
#SBATCH -t 2:20:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
export OMP_NUM_THREADS=48
export KS_IC_NT=48
export GSKNN_IC_NT=48

cd $MISDIR/matlab

source askit/sourceme.s2.askit

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ones -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file ${onesfile} \
-test_potentials_file None -num_power_iterations 10 -test_data_file None -test_knn_file None \
-num_test_points 0 -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_training_potentials

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${ppvfile} \
-N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file ${yyfile} \
-test_potentials_file None -num_power_iterations 10 -test_data_file None -test_knn_file None \
-num_test_points 0 -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_training_potentials

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${rofilein} \
-N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file ${rofile} \
-test_potentials_file None -num_power_iterations 10 -test_data_file None -test_knn_file None \
-num_test_points 0 -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_training_potentials

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${cmfilein} \
-N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file ${cmfile} \
-test_potentials_file None -num_power_iterations 10 -test_data_file None -test_knn_file None \
-num_test_points 0 -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_training_potentials
" > ${filen}.job

# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    sbatch ${filen}.job 
    rm ${filen}.job
else
    cat ${filen}.job
fi
#
#
#tfilen=ktst.${FKEEP}.${STYPE}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}
#tstfile=$(ls ${OUTDIR}/knntst.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
#IFS='.' read -ra delims <<< ${tstfile}
#n_que=${delims[-2]};
#knnfile=${tstfile%.bin}.kk.${KK}.bin;
#knnfile=${knnfile/knntst/nntstlist};
#
#
#echo "#!/bin/bash
##SBATCH -J ${tfilen} # Job name
##SBATCH -o ${tfilen}.o # Name of stdout output file
##SBATCH -e ${tfilen}.e # Name of stderr error file
##SBATCH -p skx-normal # Queue name
##SBATCH -N 8 # Total # of nodes (now required)
##SBATCH -n 256 # Total # of mpi tasks
##SBATCH -t 10:00:00 # Run time (hh:mm:ss)
##SBATCH --mail-user=sameer@ices.utexas.edu
###SBATCH --mail-type=begin # Send email at begin and end of job
##SBATCH --mail-type=end # Send email at begin and end of job
##SBATCH -A PADAS # Allocation name (req'd if more than 1)
#
## Run trn/tst list creation on skx s2 nodes
#echo $(date) Begin
#pwd
#module load matlab/2017a
#
#cd $MISDIR/matlab
#
#source knn/sourceme.s2.knn
#
#ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe -ref_file ${trnfile} -query_file ${tstfile} -knn_file ${knnfile} -glb_nref ${n_ref} -glb_nquery ${n_que} -dim ${FKEEP} -k ${KK} -mtl 30 -mppn 2500 -iter 150 -binary -eval" > ${tfilen}.job
#
#
## If test, cat file, o.w. sbatch and rm
#if [ ! $TEST ]
#then
#    sbatch ${tfilen}.job 
#    rm ${tfilen}.job
#else
#    cat ${tfilen}.job
#fi
