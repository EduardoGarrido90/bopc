for ((i=1;i<=40;i+=1)); do
	
	echo Replica number $i
    mkdir -p exp_results/pes_${i}
    mkdir -p exp_results/random_${i}
    mkdir -p exp_results/expert_${i}

    cp -r -p exp_templates/pes/* exp_templates/run_Rserve.R -t exp_results/pes_${i}/
    cp -r -p exp_templates/random/* exp_templates/run_Rserve.R -t exp_results/random_${i}/
    cp -r -p exp_templates/expert/* exp_templates/run_Rserve.R -t exp_results/expert_${i}/

    sed -i -- "s/index=1/index=${i}/g" exp_results/pes_${i}/run_experiment.sh
    sed -i -- "s/index=1/index=${i}/g" exp_results/random_${i}/run_experiment.sh
    sed -i -- "s/index=1/index=${i}/g" exp_results/expert_${i}/run_experiment.sh

    sed -i -- "s/NUM_EXP = 1/NUM_EXP = ${i}/g" exp_results/pes_${i}/wrapper.py
    sed -i -- "s/NUM_EXP = 1/NUM_EXP = ${i}/g" exp_results/random_${i}/wrapper.py
    sed -i -- "s/NUM_EXP = 1/NUM_EXP = ${i}/g" exp_results/expert_${i}/wrapper.py

    sed -i -- "s/\"random_seed\"     : 1/\"random_seed\"     : ${i}/g" exp_results/pes_${i}/config.json
    sed -i -- "s/\"random_seed\"     : 1/\"random_seed\"     : ${i}/g" exp_results/random_${i}/config.json

    sed -i -- "s/\"experiment-name\" : \"bn_shd_pes_1\"/\"experiment-name\" : \"bn_shd_pes_${i}\"/g" exp_results/pes_${i}/config.json
    sed -i -- "s/\"experiment-name\" : \"bn_shd_random_1\"/\"experiment-name\" : \"bn_shd_random_${i}\"/g" exp_results/random_${i}/config.json

	#Launch experiment.
	(cd exp_results/pes_${i}/ && ./run_experiment.sh)
        (cd exp_results/random_${i}/ && ./run_experiment.sh)
        (cd exp_results/expert_${i}/ && ./run_experiment.sh)
done
