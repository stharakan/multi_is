#!/bin/bash
source ./Parser.sh

filen=ktrn.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# find n_ref, trnfile, and knnfile
trnfile=$(ls ${OUTDIR}/knntrn.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${trnfile}
n_ref=${delims[-2]};
knnfile=${trnfile%.bin}.kk.${KK}.bin;
knnfile=${knnfile/knntrn/nntrnlist};

tfilen=ktst.${BRAIN}.${FKEEP}.${STYPE}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}
tstfile=$(ls ${OUTDIR}/knntst*${FKEEP}*${FTYPE}*${PSIZE}*${BRAIN}*bin)
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
