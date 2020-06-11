LA=function(g2,g1)
{
  # normalize=function(x)
  # {
  #   x=as.numeric(as.vector(x))
  #   return((x-mean(x))/sd(x))
  # }
  exp1=rna.exp[g1,]
  exp2=rna.exp[g2,]
  la=NA
  share.micro=colnames(target)[which(target[g1,]&target[g2,])]
  if(length(share.micro)>1)
  {
    Z=colSums(micro.exp[share.micro,])
    tZ=qnorm(rank(Z)/(length(Z)+1))
    la=mean(exp1*exp2*tZ)
  }
  else if(length(share.micro)==1)
  {
    Z=micro.exp[share.micro,]
    tZ=qnorm(rank(Z)/(length(Z)+1))
    la=mean(exp1*exp2*tZ)
  }
  return(la)
}