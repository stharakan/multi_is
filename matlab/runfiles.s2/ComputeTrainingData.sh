#!/bin/bash
# This is a script to create training datasets. Specifically, 
# it follows the following pipeline:
# 
# 1. Select points/patches
# 2. Compute features
# 3. Run feature selection
# 4. Prepare data for NN compute/askit
#

# process command line
./Parser.sh

# Make list (i.e. select points)
STROUT=$(./MakeLists.sh -s ${PSSTR} -p ${PSP1} -q ${PSIZE})  
LISTID=$(echo "${STROUT##* }")
echo $LISTID

# Compute features
STROUT=$(./MakeFeatures.sh -D ${LISTID} -s ${PSSTR} -p ${PSP1} -q ${PSIZE} -f ${FTYPE}) 
FEATID=$(echo "${STROUT##* }")
echo $FEATID

# Feature selection 
STROUT=$(./RunFeatureSelection.sh -D ${LISTID} -s ${PSSTR} -p ${PSP1} -q ${PSIZE} -f ${FTYPE} -o ${TARGET}) 
FSELID=$(echo "${STROUT##* }")
echo $FSELID

# NN/ASKIT prep 
STROUT=$(./PreprocessKnn.sh -D ${LISTID} -s ${PSSTR} -p ${PSP1} -q ${PSIZE} -f ${FTYPE} -o ${TARGET} -k ${KK}) 
NNID=$(echo "${STROUT##* }")
echo $NNID


