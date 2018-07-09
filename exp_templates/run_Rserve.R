############################################################################
#run_Rserve.R
#R utility that launches Rserve, which waits for Rserve calls from other 
#languages ( Python, Java ) and serves that call executing the R code
#that is sent as a parameter. It outputs the computation of that code.
#INPUT: Port that Rserve will listen to. Integer positive number. Mandatory.
#OUTPUT: Every time Rserve is called, it outputs the computation of the code
#that is given as a parameter.
#IMPORTANT: If Rserve runs wild, the only way to shutdown it is:
# 	-> 1. Retrieve Rserve pid: "ps -ef | grep Rserve" helps.
#	-> 2. A kill will not shutdown Rserve "kill pid_rserve",
#	as it is protected to the SIGQUIT signal. We need to call
#	kill with the SIGTERM signal (15). "kill -15 pid_rserve".
############################################################################

library(Rserve)
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0){
	stop("At least one argument must be supplied")
} else {
	run.Rserve(debug = TRUE, port = args[1], remote=TRUE, auth=FALSE, args="--no-save")
}
