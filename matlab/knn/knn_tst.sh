#!/bin/bash
kk=512

for tstfile in $PRDIRSCRATCH/knntst*patchstats*.5.*8000*
do 
    echo ${tstfile}
    
    # set up vars -- need n_ref and dd
    IFS='.' read -ra delims <<< ${tstfile}
    #echo "nn is ${delims[-2]}"
    #echo "ft is ${delims[1]}"
    ft=${delims[1]};
    n_que=${delims[-2]};
    ps=${delims[3]};
    sel1=${delims[4]};
    sel2=${delims[6]};
    tmpfile=${ft}.tst.${n_que}.${ps}.job
    
    # find training?
    trnfile=$PRDIRSCRATCH/knntrndata*${ft}*${ps}*.${sel1}.*.${sel2}.*;
    echo ${trnfile}
    IFS='.' read -ra delims <<< ${trnfile}
    n_ref=${delims[-2]};
    
    knnfile=${tstfile%.bin}.kk.${kk}.bin;
    knnfile=${knnfile/knntstdata/knntstlist};
    
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
#SBATCH -J knntst # Job name
#SBATCH -o knntst.o%j # Name of stdout output file
#SBATCH -e knntst.e%j # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 1 # Total # of nodes (now required)
#SBATCH -n 48 # Total # of mpi tasks
#SBATCH -t 2:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
#SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# This script does knn search for a train set
echo $(date) Begin
pwd

export OMP_NUM_THREADS=96
source sourceme.s2.knn

# stampede2 or maverick
ibrun tacc_affinity /home1/02497/jll2752/lib/knn/src/parallelIO/test_find_knn.exe -ref_file ${trnfile} -query_file ${tstfile} -knn_file ${knnfile} -glb_nref ${n_ref} -glb_nquery ${n_que} -dim ${dd} -k ${kk} -mtl 30 -mppn 2500 -iter 150 -binary -eval" > ${tmpfile}

    sbatch ${tmpfile}
    #rm ${tmpfile}
    
done

