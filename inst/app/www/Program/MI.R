MI=function(g2,g1,param)
{
  library(infotheo)
  return(mutinformation(X = rna.exp[g1,],Y = rna.exp[g2,], method = param$est))
}