#!/bin/bash

brainarr=(Brats17_2013_18_1 Brats17_CBICA_ABO_1 Brats17_CBICA_ATP_1 Brats17_TCIA_147_1 Brats17_TCIA_298_1 Brats17_TCIA_378_1 Brats17_TCIA_637_1);

featarr=(patchgabor patchstats patchgstats)
featarr=(patchgstats)

psizearr=(5 9 17)
p1arr=(0.25 0.2 0.15)

featarr=(patchgstats)
psizearr=(5)
p1arr=(0.25)
for fname in "${featarr[@]}";
do 

    for index in ${!psizearr[*]};
    do 
    
        psize=${psizearr[$index]};
        psp1=${p1arr[$index]};
        
        echo "Param: ${psp1}";
        echo "Psize: ${psize}";
        echo "Ftype: ${fname}";

        for brain in "${brainarr[@]}";
        do
            # data creation
            #STROUT=$(./TstBrnDataCreate.sh -s edemadist -n ${brain} -f ${fname} -p ${psp1} -q ${psize}) 
            #DATAID=$(echo "${STROUT##* }")
            #echo $DATAID
            
            
            
            STROUT=$(./BrainKnn.sh -s edemadist -n ${brain} -f ${fname} -p ${psp1} -q ${psize})
            NNID=$(echo "${STROUT##* }")
            echo $NNID
            
            
            #STROUT=$(./BrainAskit.sh -s edemadist -n ${brain} -f ${fname} -p ${psp1} -q {psize} -t)
            #echo $STROUT
            ##STROUT=$(./BrainAskit.sh -n ${brain} -f ${fname} -p ${psp1} -q {psize} -D ${NNID} -t)
            #ASKID=$(echo "${STROUT##* }")
            #echo $ASKID
            #
            #
            #STROUT=$(./BrainPostAskit.sh -D ${NNID})
            #ASKID=$(echo "${STROUT##* }")
            #echo $ASKID

        
        done;

    done;

done;















































































