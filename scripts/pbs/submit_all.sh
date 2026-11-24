#! /bin/bash 

#PBS -N ControlJobsSokoban13
#PBS -l nodes=1:ppn=1,mem=1gb,walltime=1100:00:00
#PBS -q roteamento

cd "$(dirname "$0")/../.."   # submit from the repository root so PBS_O_WORKDIR points there

# instance to be tested
INSTANCES='instance_01.map
instance_02.map
instance_03.map
instance_04.map
instance_05.map
instance_06.map
instance_07.map
instance_08.map
instance_09.map
instance_10.map
instance_11.map
instance_12.map
instance_13.map
instance_14.map
instance_15.map
instance_16.map
instance_17.map
instance_18.map
instance_19.map
instance_20.map
instance_21.map
instance_22.map
instance_23.map
instance_24.map
instance_25.map
instance_26.map
instance_27.map
instance_28.map
instance_29.map
instance_30.map
instance_31.map
instance_32.map
instance_33.map
instance_34.map
instance_35.map
instance_36.map
instance_37.map
instance_38.map
instance_39.map
instance_40.map
instance_41.map
instance_42.map
instance_43.map
instance_44.map
instance_45.map
instance_46.map
instance_47.map
instance_48.map
instance_49.map
instance_50.map
instance_51.map
instance_52.map
instance_53.map
instance_54.map
instance_55.map
instance_56.map
instance_57.map
instance_58.map
instance_59.map
instance_60.map
instance_61.map
instance_62.map
instance_63.map
instance_64.map
instance_65.map
instance_66.map
instance_67.map
instance_68.map
instance_69.map
instance_70.map
instance_71.map
instance_72.map
instance_73.map
instance_74.map
instance_75.map
instance_76.map
instance_77.map
instance_78.map
instance_79.map
instance_80.map
instance_81.map
instance_82.map
instance_83.map
instance_84.map
instance_85.map
instance_86.map
instance_87.map
instance_88.map
instance_89.map
instance_90.map'

HEURISTICS='pdb1
pdb2
pdb3r
pdb4r
pdb2_2oc
pdb3r_3ocr
pdb4r_4ocr
2oc_pdb2
3ocr_pdb3r
4ocr_pdb4r
wpdb1_pdb1
wpdb2_pdb2'
#wpdb3r_pdb3r
#wpdb4r_pdb4r
#wpdb2_pdb2_2oc
#wpdb3r_pdb3r_3ocr
#wpdb4r_pdb4r_4ocr
#wpbd2_2oc_pdb2
#wpbd3r_3ocr_pdb3r
#wpdb4r_4ocr_pdb4r'

LIMIT_TIME='3600'

TIMES='01
02
03
04
05'

#---------------------------------------------------------------------------------------------------------------

for times in ${TIMES}
do
	for heur in ${HEURISTICS}
	do
		for i in ${INSTANCES}
		do
			name2=`basename ${i} .map`

				(qsub -v NAME=${name2},HEUR=${heur},TIME=${LIMIT_TIME},RUN=${times} scripts/pbs/job.sh) &    
				#(qsub -l nodes=1:STANDARD:ppn=1,mem=9gb -v NAME=${name2},ALG=${ALGORITHM},HEUR=${heur},TIME=${t} Sokoban.sh) &     
		
				q=$(qselect -u "$USER" | wc -l)
				while [ "$q" -gt "30" ]
				do
					echo "$q"
					sleep 30
					q=$(qselect -u "$USER" | wc -l)

				done	
			
		done
	done
done

