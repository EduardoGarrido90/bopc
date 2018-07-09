library("pcalg")
library("bnlearn")

size_nodes <- c(25, 50, 75, 100)
size_neighbors <- c(2, 8)
size_samples <- c(10, 50, 100, 500)
replicates <- 40

wd <- getwd()
dir.create(path = paste0(wd, "/data"), showWarnings = FALSE)

# Perform simulations
for (r in seq_len(replicates)) {
	for (p in size_nodes) {
		for (n in size_neighbors) {
			dag <- pcalg::randomDAG(n = p, prob = min(1, n/(p - 1)))
			saveRDS(object = bnlearn::as.bn(dag, check.cycles = TRUE), 
						file = paste0("data/", p, "_", n, "_r", r, ".rds"))
			for (N in size_samples) {
				sample <- pcalg::rmvDAG(n = N, dag = dag)
				saveRDS(object = as.data.frame(sample), 
							file = paste0("data/", p, "_", n, "_r", r, "_", N, ".rds"))
			}
		}
	}
}


