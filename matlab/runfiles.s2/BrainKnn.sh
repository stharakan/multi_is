#!/bin/bash
source ./Parser.sh

# find n_ref, trnfile, and knnfile
trnfile=$(ls ${OUTDIR}/knntrn.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${trnfile}
delims=(${delims});
n_ref=${delims[-2]};

filen=ktst.${BRAIN}.${FKEEP}.${STYPE}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}
#tstfile=$(ls ${OUTDIR}/knntst*${FKEEP}*${FTYPE}*${PSIZE}*${BRAIN}*bin) #we can know this right?? -> then we don't have to wait.. 
#IFS='.' read -ra delims <<< ${tstfile}
#n_que=${delims[-2]};
n_que=8928000
tstfile=${OUTDIR}/knntst.dd.${FKEEP}.${FTYPE}.ps.${PSIZE}.${BRAIN}.nn.${n_que}.bin;
knnfile=${tstfile%.bin}.kk.${KK}.bin;
knnfile=${knnfile/knntst/nntstlist};

source $MISDIR/matlab/knn/sourceme.mav.knn #get knn dir

echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p gpu # Queue name
#SBATCH -N 16 # Total # of nodes (now required)
#SBATCH -n 16 # Total # of mpi tasks
#SBATCH -t 4:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2017a

export OMP_NUM_THREADS=68
cd $MISDIR/matlab

source knn/sourceme.mav.knn

ibrun tacc_affinity ${KNN_DIR}/parallelIO/test_find_knn.exe -ref_file ${trnfile} -query_file ${tstfile} -knn_file ${knnfile} -glb_nref ${n_ref} -glb_nquery ${n_que} -dim ${FKEEP} -k ${KK} -mtl 30 -mppn 2500 -iter 100 -binary -eval" > ${filen}.job


# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    if [ -z "$JID" ]
    then
        sbatch ${filen}.job
    else
        sbatch --dependency=afterok:${JID} ${filen}.job
    fi
    #rm ${filen}.job
else
    cat ${filen}.job
fi
