#!/bin/bash
kk=512
dd=30


for trnfile in $PRDIRSCRATCH/knntrn*patchgabor*
do 
    echo $trnfile
    # set up vars -- need n_ref and dd
    IFS='.' read -ra delims <<< ${trnfile}
    #echo "nn is ${delims[-2]}"
    #echo "ft is ${delims[1]}"
    ft=${delims[1]};
    n_ref=${delims[-2]};
    ps=${delims[3]};
    tmpfile=${ft}.${n_ref}.${ps}.job
    knnfile=${trnfile%.bin}.kk.${kk}.bin;
    
    # dd
    if [ "${ft}" == "patchstats" ]; then
        dd=16;
    elif [ "${ft}" == "patchgabor" ]; then
        if [ "${ps}" == "5" ]; then
            dd=96;
        elif [ "${ps}" == "9" ]; then
            dd=128;
        elif [ "${ps}" == "17" ]; then
            dd=160;
        elif [ "${ps}" == "33" ]; then
            dd=160;
        fi
    elif [ "${ft}" == "patchgstats" ]; then
        if [ "${ps}" == "5" ]; then
            dd=72;
        elif [ "${ps}" == "9" ]; then
            dd=96;
        elif [ "${ps}" == "17" ]; then
            dd=120;
        elif [ "${ps}" == "33" ]; then
            dd=120;
        fi
    fi

    echo "#!/bin/bash
#SBATCH -J knntrn # Job name
#SBATCH -o knntrn.o%j # Name of stdout output file
#SBATCH -e knntrn.e%j # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 16 # Total # of nodes (now required)
#SBATCH -n 512 # Total # of mpi tasks
#SBATCH -t 2:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
#SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# This script does knn search for a train set
echo $(date) Begin
pwd

source sourceme.s2.knn

# stampede2 or maverick
ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe -ref_file ${trnfile} -knn_file ${knnfile} -glb_nref ${n_ref} -dim ${dd} -k ${kk} -mtl 30 -mppn 2500 -iter 150 -binary -search_all2all -eval" > ${tmpfile}
    sbatch ${tmpfile}
    rm ${tmpfile}
    
done

#echo "#!/bin/bash
##SBATCH -J knntst${ps} # Job name
##SBATCH -o knntst${ps}.o%j # Name of stdout output file
##SBATCH -e knntst${ps}.e%j # Name of stderr error file
##SBATCH -p skx-normal # Queue name
##SBATCH -N 16 # Total # of nodes (now required)
##SBATCH -n 512 # Total # of mpi tasks
##SBATCH -t 2:00:00 # Run time (hh:mm:ss)
##SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
##SBATCH --mail-type=end # Send email at begin and end of job
##SBATCH -A PADAS # Allocation name (req'd if more than 1)
#
## This script does knn search for a train set
#echo $(date) Begin
#pwd
#
#source sourceme.s2.knn
#
## stampede2 or maverick
#ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe \
#-ref_file ${PRDIR}/onlystats.ps.${ps}.nn.${n_ref}.dd.${dd}.XX.trn.bin \
#-query_file ${PRDIR}/onlystats.ps.${ps}.nn.${n_que}.dd.${dd}.XX.tst.bin \
#-knn_file ${PRDIRSCRATCH}/knnfiles/onlystats.ps.33.nn.${n_que}.dd.${dd}.kk.${kk}.bin \
#-glb_nref ${n_ref} -glb_nquery ${n_que} -dim ${dd} -k ${kk} -mtl 30 -mppn 2500 -iter 150 -binary -eval" > knn${ps}.job
#sbatch knn${ps}.job
