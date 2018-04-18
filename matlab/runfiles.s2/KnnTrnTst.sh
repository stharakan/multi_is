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
KK=512;
BW=0.37;

# Process command line
usage="$(basename "$0") [-h] [-?] [-b -d -s -o -p -q -f -k -w -n -t] -- run trn/tst list creation 

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
  -n  Number of neighbors
  -t  output sbatch file, don't run"

while getopts "h?b:d:s:o:p:q:f:k:n:tP:" opt; do
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
    n) KK=$OPTARG
      ;;
  esac
done

filen=ktrn.${BW}.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# find n_ref, trnfile, and knnfile
trnfile=$(ls ${OUTDIR}/knntrn.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${trnfile}
n_ref=${delims[-2]};
knnfile=${trnfile%.bin}.kk.${KK}.bin;
knnfile=${knnfile/knntrn/nntrnlist};
# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 8 # Total # of nodes (now required)
#SBATCH -n 256 # Total # of mpi tasks
#SBATCH -t 10:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2017a

cd $MISDIR/matlab

source knn/sourceme.s2.knn
ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe -ref_file ${trnfile} -knn_file ${knnfile} -glb_nref ${n_ref} -dim ${FKEEP} -k ${KK} -mtl 30 -mppn 2500 -iter 100 -binary -search_all2all -eval

" > ${filen}.job

# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    sbatch ${filen}.job 
    rm ${filen}.job
else
    cat ${filen}.job
fi


tfilen=ktst.${FKEEP}.${STYPE}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}
tstfile=$(ls ${OUTDIR}/knntst.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${tstfile}
n_que=${delims[-2]};
knnfile=${tstfile%.bin}.kk.${KK}.bin;
knnfile=${knnfile/knntst/nntstlist};


echo "#!/bin/bash
#SBATCH -J ${tfilen} # Job name
#SBATCH -o ${tfilen}.o # Name of stdout output file
#SBATCH -e ${tfilen}.e # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 8 # Total # of nodes (now required)
#SBATCH -n 256 # Total # of mpi tasks
#SBATCH -t 10:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2017a

cd $MISDIR/matlab

source knn/sourceme.s2.knn

ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe -ref_file ${trnfile} -query_file ${tstfile} -knn_file ${knnfile} -glb_nref ${n_ref} -glb_nquery ${n_que} -dim ${FKEEP} -k ${KK} -mtl 30 -mppn 2500 -iter 100 -binary -eval" > ${tfilen}.job


# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    sbatch ${tfilen}.job 
    rm ${tfilen}.job
else
    cat ${tfilen}.job
fi
