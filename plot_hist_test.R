library("ggplot2")

wd <- getwd()
dir.create(paste0(wd, "/img"), showWarnings = FALSE)

method_names <- c('Bayesian Optimization (PES)', 'Random', 'Expert')
size <- 30
n_simulations <- 40
results <- matrix("", n_simulations, length(method_names))
counter <- 1
for (i in 1 : n_simulations) {
    correct <- T

    hyper_volume_solution <- -Inf
    for (j in 1 : length(method_names)) {
		if (method_names[j] == 'Bayesian Optimization (PES)') {
            file_name <- paste("./paper_results/pes_",i,"/params_transformed.txt", sep ="")
        }
        else if (method_names[j] == 'Random'){
            file_name <- paste("./paper_results/random_", i, "/params_transformed.txt", sep = "")
        }
		if(method_names[j] == 'Bayesian Optimization (PES)' | method_names[j] == 'Random')
		{
        	if (!file.exists(file_name))
            		correct <- F
	        else {
        	    current_results <- read.table(file_name,sep=",")$V1

	            if (is.na(current_results[size]))
        	        correct <- F
	            else {
                	results[ counter, j ] <- toString(current_results[size])
        	    }
	        }
		} else {
			results[ counter, j ] <- 'zf'
		}
    }
    if (correct) {
        counter <- counter + 1
    }
}

results_frame <- data.frame(results)
colnames(results_frame) <- c("Bayesian Optimization", "Random", "Expert")

ggplot(results_frame["Bayesian Optimization"], col="black", aes(x=results[,1], fill= ..count..)) + geom_bar(colour="black") + 
	xlab("Tests") +
	scale_fill_gradient("", low = "grey", high = "grey") +
	ylab("Absolute frequency") +
	labs(title="Bayesian optimization test recommendations") +
	theme_bw() +
	theme(plot.title = element_text(size = 25)) +
    	theme(axis.title=element_text(size = 25)) +
    	theme(axis.text.x = element_text(angle = 00, hjust = 0.5, size=19, color="black")) +
    	theme(axis.text.y = element_text(angle = 00, hjust = 0.5, size=23, color="black")) +
	theme(legend.position="none")+
	ggsave("./img/hist_test.pdf", width = 9, height =4.9)
