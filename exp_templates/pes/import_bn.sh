#Selecting one BN to train at random and import it into experiment directory.
data_route=/home/proyectos/ada2/egarrido/bo_bayesian_networks/bayes-net-opt/exp/sim/data
num_networks=`ls $data_route | grep dag | wc -l`
selected_network_index=`echo $RANDOM % $num_networks + 1 | bc`
selected_bn_file=`ls $data_route | grep dag | sed "${selected_network_index}q;d"`
selected_bn_alternative_file=${selected_bn_file//_dag/}
echo $selected_bn_file
echo $selected_bn_alternative_file
cp $data_route/$selected_bn_file true_bn_dag.rds
cp $data_route/$selected_bn_alternative_file sample_bn.rds
