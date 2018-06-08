#!/bin/bash
# Process command line
source ./Parser.sh

filen=trndata.${FKEEP}.${STYPE}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}


# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p normal # Queue name
#SBATCH -N 1 # Total # of nodes (now required)
#SBATCH -n 1 # Total # of mpi tasks
#SBATCH -t 5:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
##SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
module load matlab/2017a

cd $MISDIR/matlab

matlab -r \"TrnDataCompute('${BDIR}','alltrn','${OUTDIR}', '${PSSTR}', ${PSP1},${PSIZE},'${FTYPE}','${STYPE}', ${FKEEP},${TARGET} ); quit\"  
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
