#! /bin/bash 

#(qsub -l nodes=1:STANDARD:ppn=1,mem=1gb qsub_sokoban.sh) 
cd /home/damaris/git/IJCAI-19/GBFS/Local_Search_IJCAI_18.01.19_Código/

(qsub qsub_sokoban.sh) &

