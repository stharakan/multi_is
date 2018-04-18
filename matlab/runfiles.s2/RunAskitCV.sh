#!/bin/bash

# features to loop over
featarr=(patchgabor patchstats patchgstats)

# relevant psizes/p1
psizearr=(5 9 17)
p1arr=(0.25 0.2 0.15)


for fname in "${featarr[@]}";
do 

    for index in ${!psizearr[*]};
    do 
    
        psize=${psizearr[$index]};
        psp1=${p1arr[$index]};
        
        echo "Param: ${psp1}";
        echo "Psize: ${psize}";
        echo "Ftype: ${fname}";
        
        STROUT=$(./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10)
        PREID=$(echo "${STROUT##* }")
        echo $PREID
        
        STROUT=$(./AskitMultiplyCV.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10 -D ${PREID})
        CVID=$(echo "${STROUT##* }")
        echo $CVID
        
        STROUT=$(./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10 -D ${CVID})
        POSTID=$(echo "${STROUT##* }")
        echo $POSTID
    
    done;

done

