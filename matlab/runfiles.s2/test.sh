#!/bin/bash


#./AskitMultiplyCV.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10 -t

featarr=(patchgabor patchstats patchgstats)
featarr=(patchstats)

psizearr=(5 9 17)

p1arr=(0.25 0.2 0.15)
#p1arr=(0.15)

for fname in "${featarr[@]}";
do 

    for index in ${!psizearr[*]};
    do 
    
        psize=${psizearr[$index]};
        psp1=${p1arr[$index]};
        
        echo "Param: ${psp1}";
        echo "Psize: ${psize}";
        echo "Ftype: ${fname}";
        
        #STROUT=$(./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10)
        #PREID=$(echo "${STROUT##* }")
        #echo $PREID
        #
        #STROUT=$(./AskitMultiplyCV.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10 -D ${PREID})
        #CVID=$(echo "${STROUT##* }")
        #echo $CVID
        
        #STROUT=$(./CVBandwidthAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10)
        #STROUT=$(./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10 -D ${CVID})
        #POSTID=$(echo "${STROUT##* }")
        
        STROUT=$(./AskitMultiply.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10)
        #STROUT=$(./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p ${psp1} -q ${psize} -f ${fname} -k 10 -D ${CVID})
        POSTID=$(echo "${STROUT##* }")
        echo $POSTID
    
    done;

done

#./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10 
#./AskitMultiplyCV.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10
#./AskitMultiply.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10 -w 1.01 
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchgabor -k 10 -w 0.99
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchgabor -k 10 -w 0.78
#
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgstats -k 10 -w 0.98
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchgstats -k 10 -w 0.99
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchgstats -k 10 -w 0.68
#
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchstats -k 10 -w 1.36
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchstats -k 10 -w 1.14
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchstats -k 10 -w 0.93

#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchgabor -k 10 
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchgabor -k 10 
#
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgstats -k 10
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchgstats -k 10
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchgstats -k 10
#
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchstats -k 10
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchstats -k 10
#./PostprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchstats -k 10


#./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.15 -q 17 -f patchgabor -k 10 -w 10.1
#./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.2 -q 9 -f patchgabor -k 10 -w 9.93
#./PreprocessAskit.sh -s edemadist -n 1024 -c 10 -p 0.25 -q 5 -f patchgabor -k 10 -w 7.157

#./PreprocessKnn.sh -s edemadist -p 0.15 -q 17 -f patchgstats -k 30
#./PreprocessKnn.sh -s edemadist -p 0.15 -q 17 -f patchgabor -k 30
#./PreprocessKnn.sh -s edemadist -p 0.2 -q 9 -f patchgstats -k 30
#./PreprocessKnn.sh -s edemadist -p 0.2 -q 9 -f patchgabor -k 30
#./PreprocessKnn.sh -s edemadist -p 0.25 -q 5 -f patchgstats -k 30
#./PreprocessKnn.sh -s edemadist -p 0.25 -q 5 -f patchgabor -k 30
#
#./PreprocessKnn.sh -s edemadist -p 0.15 -q 17 -f patchgabor -k 60
#./PreprocessKnn.sh -s edemadist -p 0.15 -q 17 -f patchgstats -k 60
#./PreprocessKnn.sh -s edemadist -p 0.2 -q 9 -f patchgstats -k 60
#./PreprocessKnn.sh -s edemadist -p 0.2 -q 9 -f patchgabor -k 60
#./PreprocessKnn.sh -s edemadist -p 0.25 -q 5 -f patchgstats -k 60
#./PreprocessKnn.sh -s edemadist -p 0.25 -q 5 -f patchgabor -k 60
