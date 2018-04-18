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
KCUT=8;
BW=1
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


filen=aposcv.${KCUT}.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 1 # Total # of nodes (now required)
#SBATCH -n 20 # Total # of mpi tasks
#SBATCH -t 0:20:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2017a

cd $MISDIR/matlab

matlab -r \"CVPostprocessForASKIT('${OUTDIR}',${PSIZE}, '${FTYPE}', '${PSSTR}',${PSP1},${TARGET} ); quit\"  

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
