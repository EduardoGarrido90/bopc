library("ggplot2")

wd <- getwd()
dir.create(paste0(wd, "/img"), showWarnings = FALSE)

method_names <- c('BO', 'RS', 'EC')
size <- 30
n_simulations <- 40
results <- list()
for (i in 1 : length(method_names))
	results[[ i ]] <- matrix(0, n_simulations, size)

counter <- 1
for (i in 1 : n_simulations) {
	correct <- T
	
	hyper_volume_solution <- -Inf
	for (j in 1 : length(method_names)) {
		if (method_names[j] == 'BO') {
			file_name <- paste("./paper_results/pes_",i,"/value_solution_om.txt", sep ="")
		}
		else if (method_names[j] == 'RS'){
			file_name <- paste("./paper_results/random_", i, "/value_solution_om.txt", sep = "")
		}
		if(method_names[j] == 'BO' | method_names[j] == 'RS')
		{
			if (!file.exists(file_name))
				correct <- F
			else {
				current_results <- read.table(file_name)$V1[ 1 : size ]
				
				
				if (is.na(current_results[size]))
					correct <- F
				else {
					results[[ j ]][ counter, ] <- current_results
				}
			}
		}
		else{
			if(method_names[j] == 'EC') {
				current_results <- read.table(paste("./paper_results/expert_", i,"/error.txt", sep=""))$V1[ 1 : 1 ]
				results[[ j ]][ counter, ] <- rep( current_results, size )
			} 	
		}
	}
	if (correct) {
		counter <- counter + 1
	}
}

best <- NULL

for (i in 1 : nrow(results[[ 1 ]])) {
	best_value <- Inf
	
	for (j in 1 : length(method_names)) {
		best_value <- min(best_value, results[[ j ]][ i, ])
	}
	
	best <- c(best, best_value)
	
}

for (j in 1 : length(method_names)) {
	for (i in 1 : nrow(results[[ 1 ]])) {
		results[[ j ]][ i, ] <- log(results[[ j ]][ i, ]  - best[ i ] + 1e-3)
	}
}

for (j in 1 : length(method_names)) {
	results[[ j ]] <- results[[ j ]][ 1 : (counter - 1), ]
}

mean_value <- matrix(0,length(method_names), size)
sd_value <- matrix(0, length(method_names),size) 

for (i in 1 : length(method_names)) {
	
	mean_value[ i, ] <- apply(results[[ i ]], 2, mean)
	
	n_bootstrap_samples <- 200
	bootstrap_estimator <- matrix(0, n_bootstrap_samples, size)
	for (j in 1 : n_bootstrap_samples) {
		bootstrap_estimator[ j, ] <- apply(results[[ i ]][ sample(1 : nrow(results[[ i ]]), replace = T), ], 2, mean)
	}
	
	index <- which(is.finite(rowSums(bootstrap_estimator)))
	sd_value[ i, ] <- apply(bootstrap_estimator[ index, ], 2, sd)
}

ylim <- c(0.0, 1.0)

results <- NULL
for (i in 1 : length(method_names)) {
	to_add <- cbind(rep(method_names[ i ], size), mean_value[ i, ], sd_value[ i, ], seq(1,  size))
	results <- rbind(results, to_add)
}

results <- data.frame(Methods = as.factor(results[ , 1 ]), mean = as.double(results[ , 2 ] ), sd = as.double(results[ , 3 ]),
											iteration = 1 * as.double(results[ , 4 ]))

results[ , 1 ] <- factor(results[, 1 ], levels = c("BO", "RS", "EC", "EC_2"))

pl <- ggplot(results, aes(x = iteration, y = mean, colour = Methods)) +
	geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.5, size = 0.75) +
	ylab("Log difference normalized SHD") +
	xlab("Number of function evaluations") +
	geom_line() +
	labs(title="Gaussian Bayesian network reconstruction with the PC algorithm") +
	geom_point(size = 2) +
	theme_bw() +
	theme(legend.justification = c(0, 0), legend.position= c(0.8, 0.6), legend.text = element_text(colour="black", size = 16, face = "bold"), legend.title=element_blank()) +
	geom_line(size = 0.75) +
	scale_y_continuous(breaks = seq(round(min(results$mean), 1), round(max(results$mean), 1),
																	(round(max(results$mean), 1) - round(min(results$mean), 1)) / 5)) +
	theme(plot.title = element_text(size = 17, face = "bold")) +
	theme(axis.title=element_text(size = 20, face = "bold")) +
	theme(axis.text.x = element_text(angle = 00, hjust = 0.5, size=20, color="black")) +
	theme(axis.text.y = element_text(angle = 00, hjust = 0.5, size=20, color="black")) +
	scale_color_manual(values=c("black","orange", "green", "red3", "#0072B2", "green", "purple"))

ggsave("./img/shd.pdf", plot = pl, width = 9, height = 4.9)

