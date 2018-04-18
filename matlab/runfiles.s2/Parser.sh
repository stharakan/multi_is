PSSTR='random';
PSP1=2000;
PSIZE=5;
FTYPE=patchstats
TARGET=2;
BDIR=${BRATSDIR}/preprocessed/trainingdata/meanrenorm/;
STYPE=reg01;
OUTDIR=${PRDIRSCRATCH}/
KK=512;
FKEEP=10;

usage="$(basename "$0") [-h] [-?] [-b -d -s -o -p -q -f -k -t] -- creates training datasets

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
  -t  output sbatch file, don't run"

while getopts "h?b:d:s:o:p:q:f:k:D:n:tP:" opt; do
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
    D) JID=$OPTARG
      ;;
    n) KK=$OPTARG
      ;;
  esac
done

