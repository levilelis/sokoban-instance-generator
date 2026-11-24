#!/bin/bash

#PBS -N Sokoban22
#PBS -l nodes=1:STANDARD:ppn=1,mem=9gb,walltime=2:00:00
#PBS -q qtime

cd /home/damaris/git/IJCAI-19/GBFS/Local_Search_IJCAI_18.01.19_Código/

module load boost/1.58.0
module load gcc/4.8.3

./bin/LocalSearch ${NAME} ${HEUR} ${TIME} ${RUN}



