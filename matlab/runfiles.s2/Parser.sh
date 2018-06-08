PSSTR='random';
PSP1=2000;
PSIZE=5;
FTYPE=patchstats
TARGET=2;
BDIR=${BRATSDIR}/preprocessed/trainingdata/meanrenorm/;
STYPE=reg01;
OUTDIR=${PRDIRSCRATCH}/
#OUTDIR=${PRDIR}/
KK=256;
FKEEP=10;
BW=0.37;
BRAIN=Brats17_2013_0_1;
KCUT=10;

usage="$(basename "$0") [-h] [-?] [-b -d -s -o -p -q -f -k -n -c -t] -- creates training datasets

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
  -n  Name of brain
  -K  neighbors to compute
  -c  neighbors to retain
  -t  output sbatch file, don't run"

while getopts "h?b:d:s:o:p:q:w:f:k:D:n:K:c:tP:" opt; do
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
    w) BW=$OPTARG
      ;;
    k) FKEEP=$OPTARG
      ;;
    D) JID=$OPTARG
      ;;
    K) KK=$OPTARG
      ;;
    c) KCUT=$OPTARG
      ;;
    n) BRAIN=$OPTARG
      ;;
  esac
done

