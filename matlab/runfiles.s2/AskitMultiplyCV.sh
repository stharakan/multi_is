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
JID=;

# Process command line
usage="$(basename "$0") [-h] [-?] [-b -d -s -o -p -q -f -k -c -w -t -D] -- run trn/tst list creation 

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
  -D  job dependency
  -t  output sbatch file, don't run"

while getopts "h?b:d:s:o:p:q:f:k:w:c:n:D:tP:" opt; do
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
    D) JID=$OPTARG
      ;;
  esac
done


filen=amcv.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

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
potfile=${ppvfile%.bin}.pot
yyfile=${potfile/ppv/trn.${FTYPE}.yy};
onesfile=${potfile/ppv/trn.${FTYPE}.1s};

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

bws=\$(less $OUTDIR/cvbws.${FTYPE}.${PSSTR}.ppb.${PSP1}*.bb.208.ps.${PSIZE}.t.${TARGET}.txt)
BASEyyfile=${yyfile}
BASEonesfile=${onesfile}

for BW in \${bws}
do

CURonesfile=\${BASEonesfile/trn/trn.h.\${BW}};
CURyyfile=\${BASEyyfile/trn/trn.h.\${BW}};

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ones -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h \${BW} -c 0 -p 0 -output output.out \
-training_potentials_file \${CURonesfile} \
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
-sort_method nn -kernel_type gaussian -balloon_k 0 -h \${BW} -c 0 -p 0 -output output.out \
-training_potentials_file \${CURyyfile} \
-test_potentials_file None -num_power_iterations 10 -test_data_file None -test_knn_file None \
-num_test_points 0 -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_training_potentials
done
" > ${filen}.job

# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    if [ -z "$JID" ]
    then
        sbatch ${filen}.job
    else
        sbatch --dependency=afterok:${JID} ${filen}.job
    fi
    rm ${filen}.job
else
    cat ${filen}.job
fi
