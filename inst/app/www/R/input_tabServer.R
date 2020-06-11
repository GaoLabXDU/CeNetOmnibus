connectEnsembl=function(session)
{
  removeUI(selector = "#modalbody>",multiple = T,immediate = T)
  insertUI(selector = "#modalbody", ui=create_progress("Connecting Ensembl Server..."),where = 'beforeEnd',immediate = T)
  session$sendCustomMessage('connect_biomart',"connection")
  currentSpecial<<-"hsapiens_gene_ensembl"
  currentURL<<-"www.ensembl.org"
  ensembl<<-useMart(biomart='ensembl',dataset = currentSpecial,host=currentURL,ensemblRedirect=T)
  archieves<<-listEnsemblArchives()
  specials<<-listDatasets(ensembl)
  filters<<-listFilters(ensembl)
  attributions<<-listAttributes(ensembl)
  addAttribution(session)
 
  session$sendCustomMessage('connect_biomart',"finish")
}
updateEnsembl=function(special,url,session)
{
  print(paste('Input:',special,url))
  print(paste('Current:',currentSpecial,currentURL))
  if(currentSpecial!=special|currentURL!=url)
  {
    currentSpecial<<-special
    currentURL<<-url
    session$sendCustomMessage('filter_loading',list(div='modalbody',status='ongoing'))
    ensembl=useMart(biomart='ensembl',dataset = currentSpecial,host = currentURL)
    print('connection finish')
    Sys.sleep(1)
    session$sendCustomMessage('filter_loading',list(div='modalbody',status='finish'))
    specials<<-listDatasets(ensembl)
    filters<<-listFilters(ensembl)
    attributions<<-listAttributes(ensembl)
    addAttribution(session)
  }
}
addAttribution=function(session)
{
  attr=attributions
  group=unique(attr$page)
  result=list()
  for(g in group)
  {
    tmpattr=attr[which(attr$page==g),]
    tmpattr=data.frame(id=paste(g,tmpattr$name,sep=":"),text=paste(tmpattr$name,tmpattr$description,sep=": "),stringsAsFactors = F)
    dd=list(text=g,children=tmpattr)
    result=c(result,list(dd))
  }
  result=list(results=result)
  session$sendCustomMessage('attribution_list',toJSON(result,auto_unbox = T))
}
mergeEnsembl=function(d)
{
  return(paste(unique(d),collapse = ","))
}
# ## basicObj:保存运算需要的变量
rna.exp=""
micro.exp=""
target=""
geneinfo=""
select.gene=""
# ## ensemblObj：保存ensembl需要的变量
ensembl=""#useMart(biomart='ensembl',dataset = 'hsapiens_gene_ensembl',host='www.ensembl.org',ensemblRedirect=F)
archieves=""#listEnsemblArchives()
specials=""#listDatasets(ensembl)
filters=""#listFilters(ensembl)
attributions=""#listAttributes(ensembl)
currentSpecial=""#"hsapiens_gene_ensembl"
currentURL=""#"www.ensembl.org"
select.gene=""#""
#specials=readRDS("testdata/specials.RDate")#listDatasets(ensembl)

# #Input Page Action
