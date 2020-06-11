library(parallel)
library(jsonlite)
library(infotheo)
run=function(g1,type,codepath,param)
{
  source(codepath)
  if(is.null(param))
  {
    result=t(as.matrix(unlist(lapply(X = as.list(geneset2),FUN = get(type),g1=g1))))
  }
  else
  {
    result=t(as.matrix(unlist(lapply(X = as.list(geneset2),FUN = get(type),g1=g1,param=param))))
  }
  cat(".",file = logpath,append = T)
  colnames(result)=geneset2
  rownames(result)=g1
  return(result)
}
args=commandArgs(T)
datapath=args[1]
codepath=args[2]
type=args[3]
core=as.numeric(args[4])
logpath=args[5]
tasks=args[6]
resultpath=args[7]
param=NULL
if(length(args)>7)
{
  param=args[8]
  param=gsub(pattern = "\\\"",replacement = "\"",param)
  param=fromJSON(param)
}

load(datapath)
tasks=unlist(strsplit(x = tasks,split = ";"))

allresult=list()

if(type=="MI"||type=="CMI")
{
  rna.exp=t(discretize(X = t(rna.exp),disc = param$disc,nbins = param$nbin))
}
if(type=='LA')
{
  normalize=function(x)
  {
    x=as.numeric(as.vector(x))
    return((x-mean(x))/sd(x))
  }
  rna.exp=t(apply(X = rna.exp,MARGIN = 1,FUN = normalize))
}
if(length(which(tasks=='all'))>0)
{
  geneset1=rownames(geneinfo)
  geneset2=geneset1
  
  starttime=as.numeric(Sys.time())
  cat(paste(toJSON(data.frame(task='all',time=starttime,total=length(geneset1),stringsAsFactors = F)),"\n",sep=""),file = logpath,append = T)

  cluster=makeCluster(core)
  clusterExport(cluster,varlist = ls())
  result=parLapply(cl = cluster,X = as.list(geneset1),fun = run,type=type,codepath=codepath,param=param)
  result=do.call(what = rbind,args = result)
  stopCluster(cluster)
  cat("\nFinish!\n",file = logpath,append = T)
  
  allresult=c(allresult,list(result))
  names(allresult)='all'
}else
{
  for(task in tasks)
  {
    groups=unlist(strsplit(x = task,split = "---"))
    geneset1=rownames(geneinfo)[which(geneinfo$.group==groups[1])]
    geneset2=rownames(geneinfo)[which(geneinfo$.group==groups[2])]
    
    starttime=as.numeric(Sys.time())
    cat(paste(toJSON(data.frame(task=sub(pattern = "---",replacement = " vs ",x = task),time=starttime,total=length(geneset1),stringsAsFactors = F)),"\n",sep=""),file = logpath,append = T)
    
    cluster=makeCluster(core)
    clusterExport(cluster,varlist = ls())
    result=parLapply(cl = cluster,X = as.list(geneset1),fun = run,type=type,codepath=codepath,param=param)
    result=do.call(what = rbind,args = result)
    stopCluster(cluster)
    cat("\nFinish!\n",file = logpath,append = T)
    
    allresult=c(allresult,list(result))
  }
  names(allresult)=tasks
}
cat("All Finish!\n",file = logpath,append = T)

saveRDS(object = allresult,file = resultpath)

