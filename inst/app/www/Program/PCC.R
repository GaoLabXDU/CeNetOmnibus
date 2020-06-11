args=commandArgs(T)
datapath=normalizePath(args[1],winslash = '/')
logpath=normalizePath(args[2],winslash = '/')
resultpath=normalizePath(args[3],winslash = '/')
if(file.exists(logpath)){
  file.remove(logpath)
}else{
  file.create(logpath)
}
write(x = 'Step1/3:Loading Data..',file = logpath,append = T)  
exp=readRDS(datapath)
write(x = 'Step2/3:Calculating..',file = logpath,append = T)  
cor=cor(t(exp))
write(x = 'Step3/3:Saving Results..',file = logpath,append = T)  
saveRDS(object = cor,file = resultpath,compress = T)
write(x = 'All Finish.',file = logpath,append = T)  
