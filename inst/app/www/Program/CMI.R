CMI=function(g2,g1,param)
{
  library(infotheo)
  micro=colnames(target)[which(target[g1,]&target[g2,]==T)]
  if(length(micro)==1)
  {
    S=micro.exp[micro,]
  }
  else
  {
    S=colSums(micro.exp[micro,])
  }
  S=discretize(X = S,disc = param$disc,nbins = param$nbin)
  return(condinformation(X = rna.exp[g1,],Y = rna.exp[g2,],S = S ,method = param$est))
}