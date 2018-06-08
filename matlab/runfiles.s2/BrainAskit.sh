#!/bin/bash
source ./Parser.sh

filen=askb.${BW}.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# set askit running params 
mm=64
id_rank=32
id_tol=0.00000001

# tstdata
#tstfile=$(ls ${OUTDIR}/knntst*${FKEEP}*${FTYPE}*${PSIZE}*${BRAIN}*bin) # Know this?
#IFS='.' read -ra delims <<< ${tstfile}
#n_tst=${delims[-2]};
n_tst=8928000
tstfile=${OUTDIR}/knntst.dd.${FKEEP}.${FTYPE}.ps.${PSIZE}.${BRAIN}.nn.${n_tst}.bin;
tknnfile=${tstfile%.bin}.kk.${KCUT}.bin;
tknnfile=${tknnfile/knntst/nntstlist};

# ASSUME CORRECT BW is passed!!! 
#mdlfile=$(ls ${OUTDIR}/askitregmdl.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
trnfile=$(ls ${OUTDIR}/knntrn.dd.${FKEEP}*data*${FTYPE}*ps.${PSIZE}.${PSSTR}*${PSP1}*)
IFS='.' read -ra delims <<< ${trnfile}
n_ref=${delims[-2]};
knnfile=${trnfile%.bin}.kk.${KCUT}.bin;
knnfile=${knnfile/knntrn/nntrnlist};


# charge vecs
ppvfile=$(ls ${OUTDIR}/ppv*${PSSTR}*${PSP1}*.${PSIZE}.*208.*${TARGET}*)
cmfilein=${ppvfile/ppv/cm};
rofilein=${ppvfile/ppv/ro};

# out vecs
potfile=${ppvfile%.bin}.h.${BW}.pot
yyfile=${potfile/ppv/${BRAIN}.${FTYPE}.yy};
onesfile=${potfile/ppv/${BRAIN}.${FTYPE}.1s};
cmfile=${potfile/ppv/${BRAIN}.${FTYPE}.cm};
rofile=${potfile/ppv/${BRAIN}.${FTYPE}.ro};

# sourcefile
srcfile=${MISDIR}/matlab/askit/sourceme.s2.knl.askit
source ${srcfile}


# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p normal # Queue name
#SBATCH -N 32 # Total # of nodes (now required)
#SBATCH -n 32 # Total # of mpi tasks
#SBATCH -t 2:00:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd

cd $MISDIR/matlab

#source askit/sourceme.s2.knl.askit
source ${srcfile} 

cd $PRDIRSCRATCH/coredump
ulimit -c unlimited

time ibrun tacc-affinity ${ASKIT_DIR}/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ones -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-test_potentials_file ${onesfile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials -do_test_evaluation
#-training_potentials_file None \

time ibrun tacc-affinity ${ASKIT_DIR}/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${ppvfile} -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-test_potentials_file ${yyfile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials -do_test_evaluation
#-training_potentials_file None \


time ibrun tacc-affinity ${ASKIT_DIR}/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${cmfilein} -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file None \
-test_potentials_file ${cmfile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials -do_test_evaluation

time ibrun tacc-affinity ${ASKIT_DIR}/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${rofilein} -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file None \
-test_potentials_file ${rofile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials -do_test_evaluation
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
    #rm ${filen}.job
else
    cat ${filen}.job
fi


