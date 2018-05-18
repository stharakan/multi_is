#!/bin/bash
source ./Parser.sh

filen=askb.${BW}.${FKEEP}.${TARGET}.${FTYPE}.${PSSTR}.${PSP1}.${PSIZE}

# set askit running params 
mm=256
id_rank=128
id_tol=0.00000001

# tstdata
tstfile=$(ls ${OUTDIR}/knntst*${FKEEP}*${FTYPE}*${PSIZE}*${BRAIN}*bin)
IFS='.' read -ra delims <<< ${tstfile}
n_tst=${delims[-2]};
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

# Make sbatch runfile
echo "#!/bin/bash
#SBATCH -J ${filen} # Job name
#SBATCH -o ${filen}.o # Name of stdout output file
#SBATCH -e ${filen}.e # Name of stderr error file
#SBATCH -p skx-normal # Queue name
#SBATCH -N 32 # Total # of nodes (now required)
#SBATCH -n 32 # Total # of mpi tasks
#SBATCH -t 2:20:00 # Run time (hh:mm:ss)
#SBATCH --mail-user=sameer@ices.utexas.edu
##SBATCH --mail-type=begin # Send email at begin and end of job
#SBATCH --mail-type=end # Send email at begin and end of job
#SBATCH -A PADAS # Allocation name (req'd if more than 1)

# Run trn/tst list creation on skx s2 nodes
echo $(date) Begin
pwd
export OMP_NUM_THREADS=48
export KS_IC_NT=48
export GSKNN_IC_NT=48

cd $MISDIR/matlab

source askit/sourceme.s2.askit

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ones -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file None \
-test_potentials_file ${onesfile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
-data ${trnfile} \
-knn_file ${knnfile} \
-charges ${ppvfile} -N ${n_ref} -d ${FKEEP} -k ${KCUT} -m ${mm} -id_rank ${id_rank} -min_skeleton_level 7 -id_tol ${id_tol} \
-sort_method nn -kernel_type gaussian -balloon_k 0 -h ${BW} -c 0 -p 0 -output output.out \
-training_potentials_file None \
-test_potentials_file ${yyfile} -num_power_iterations 10 \
-test_data_file ${tstfile} \
-test_knn_file ${tknnfile} \
-num_test_points ${n_tst} -num_skel_targets 2 -num_uniform_required 0 -oversampling_fac 5 -err 100 \
-num_error_repeats 10 -max_sampling_iterations 3 -adaptive_sample_size 2 -pruning_num_neighbors 0 \
-neighbors_to_pass_up 4 -lambda 0.0 -binary -do_simplified_adaptive_rank \
-do_split_k -use_adaptive_sampling -save_test_potentials


time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
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
-do_split_k -use_adaptive_sampling -save_test_potentials

time ibrun tacc-affinity /home1/02497/jll2752/lib/askit_skx/treecode/src/askit_distributed_main.exe \
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
-do_split_k -use_adaptive_sampling -save_test_potentials
" > ${filen}.job

# If test, cat file, o.w. sbatch and rm
if [ ! $TEST ]
then
    sbatch ${filen}.job 
    rm ${filen}.job
else
    cat ${filen}.job
fi


