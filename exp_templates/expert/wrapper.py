import numpy as np
import copy
import os
import pyRserve
NUM_EXP = 1
PORT = 45678
DATA_ROUTE = os.path.dirname(os.path.realpath(__file__)) + "/../../data"

def main():

	np.random.seed(NUM_EXP)

	#Parsing parameters.
	method = "pc.stable"
	test = "zf" 
	alpha = .01

	#Experiments to be carried out.
        total_SHD = 0.0
	size_nodes = np.array([25, 50, 75, 100])
        size_neighbors = np.array([2, 8])
        size_samples = np.array([10,50,100,500])
        total_experiments = size_nodes.shape[0]*size_neighbors.shape[0]*size_samples.shape[0]
        true_bn_fr = ""
        sample_bn_fr = ""
        #Connecting to pyRserve, will launch an exception is Rserve is not listening in port.   
        conn = pyRserve.connect(port=PORT)
        i=0
        for node_example in size_nodes:
                for neighbor_example in size_neighbors:
                        true_bn_fr = str(node_example) + "_" + str(neighbor_example) + "_r" + str(NUM_EXP) + ".rds"
                        for sample_example in size_samples:
                                script = "library(\"bnlearn\"); "
                                script+="bn_true <- readRDS(\""+DATA_ROUTE+"/"+true_bn_fr+"\"); "
                                sample_bn_fr = str(node_example) + "_" + str(neighbor_example) + "_r" + str(NUM_EXP) + "_" + str(sample_example) + ".rds"
                                script += "bn_data <- readRDS(\""+DATA_ROUTE+"/"+sample_bn_fr+"\"); "
                                script+=("bn_learned <- bnlearn::pc.stable(x = bn_data, test = \""+test+"\", alpha = "+str(alpha)+"); ")
                                script+="result <- shd(bn_learned, bn_true);"
                                #We send the script and wait for evaluation.
                                conn.eval(script)
                                #Once the script is finished, we retreive the result variable.
                                shd = conn.eval("result")
                                shd_norm = shd/float((node_example*(node_example-1)/2.0))
                                total_SHD += shd_norm
                                i+=1
                                print i

        conn.close()

        return { 'shd': total_SHD/float(total_experiments) }

if __name__ == "__main__":
        with open("error.txt","w") as output:
                output.write(str(main()['shd']))
