tab= tagList(HTML(paste(readLines("www/help.html"), collapse="\n")))
help_tab=tabItem(tabName = 'help',tab)
# help_tab=tabItem(tabName = "help",style='font-family:Georgia;',
#                  div(class='col-sm-8',style="float: none;display: block;margin-left: auto;margin-right: auto;",
#                      h2("CeNet Omnibus Introduction",style='font-family:Georgia'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              
#                              HTML("<P style='font-size:20px;'>The ceRNA regulation is a newly discovered post-transcriptional regulation mechanism and plays significant roles in physiological and pathological progress. The analysis of ceRNAs and ceRNA network has been widely used to detect survival biomarkers, select candidate regulators of disease genes, and pre-dict long noncoding RNA functions. However, there is no software platform to provide overall functions from construction to analysis of ceRNA networks. To solve this problem, we introduce CeNet Omnibus, a R/Shiny application, which provides a unified framework of ceRNA network construction and analysis. CeNet Omnibus is characterized by comprehensiveness, high efficiency, high expandability and user customizability, and it also offers the web-based user-friendly interface for users to obtain the output intuitionally in time.</p>"),
#                              HTML("<p style='font-size:20px;'>CeNet Omnibus consists of five components, including <strong>Data Input</strong>, <strong>Data Processing</strong>, <strong>Network Construction</strong>, <strong>Network Visualization</strong> and <strong>Netwoek Analysis</strong>. The framework of CeNet Omnibus is shown below.</p>"),
#                              HTML("<p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/framework.svg' alt='' style='max-width:100%;'></p>"),
#                              h2("How to Start"),
#                              HTML("<p style='font-size:20px;'>CeNetOmnibus depends on multiple packages, including <strong>biomaRt</strong>, <strong>circlize</strong>, <strong>colourpicker</strong>, <strong>ComplexHeatmap</strong>, <strong>DT</strong>, <strong>formattable</strong>, <strong>ggplot2</strong>, <strong>ggplotify</strong>, <strong>ggthemr</strong>, <strong>gprofiler2</strong>, <strong>igraph</strong>, <strong>infotheo</strong>, <strong>jsonlite</strong>, <strong>linkcomm</strong>, <strong>MCL</strong>, <strong>parallel</strong>, <strong>PerformanceAnalytics</strong>, <strong>plyr</strong>, <strong>ProNet</strong>, <strong>R.oo</strong>, <strong>rhandsontable</strong>, <strong>scales</strong>, <strong>shiny</strong>, <strong>shinydashboard</strong>, <strong>shinyWidgets</strong>, <strong>survival</strong>, <strong>survminer</strong>, <strong>svglite</strong>, <strong>tibble</strong>, <strong>visNetwork</strong>.</p>"),
#                              HTML("<p style='font-size:20px;'>To make sure all the dependency packages are installed, run  following codes to install dependency packages.</p>"),
#                              HTML("<blockquote><p>Download <a href='https://github.com/william0701/ceNet-Omnibus/releases/download/0.1.1/CeNetOmnibus_0.1.1.tar.gz'>CeNetOmnibus_0.1.1.tar.gz</a></p></blockquote>"),
#                              HTML("<blockquote><p>Demo data can be downloaded with <a href='https://github.com/william0701/ceNet-Omnibus/releases/download/0.1.1/demodata.zip'>demodata.zip</a>. The details about these files can be found in the <em>readme</em> in <em>demodata</em></p></blockquote>"),
#                              HTML("<p style='font-size:20px;'>Install CeNetOmnibus package from local files</p>"),
#                              HTML('<div class="highlight highlight-source-r"><pre>install.packages(<span class="pl-s"><span class="pl-pds">"</span>user_path/CeNetOmnibus_0.1.1.tar.gz<span class="pl-pds">"</span></span>,<span class="pl-v">repos</span><span class="pl-k">=</span><span class="pl-c1">NULL</span>,<span class="pl-v">type</span><span class="pl-k">=</span><span class="pl-s"><span class="pl-pds">"</span>source<span class="pl-pds">"</span></span>)</pre></div>'),
#                              h2('Data Preparation'),
#                              HTML('<p style="font-size:20px;">CeNet Omnibus demands users to upload four files for the constrction of ceRNA network, including</p>'),
#                              HTML('<ul style="font-size:20px;"><li>The expression profiles of candidate ceRNAs and microRNAs</li><li>The interaction between microRNA and candidate ceRNAs</li><li>Essential information of candidate ceRNAs, eg. symbols, biotypes, and etc.</li></ul>'),
#                              h2('Get Start'),
#                              HTML('<p style="font-size:20px;">The following commands should be used to start CeNet Omnibus.</p>'),
#                              HTML('<div class="white"><div class="highlight"><pre><span id="LC1" class="line"><span class="n">library</span><span class="p">(</span><span class="n">CeNetOmnibus</span><span class="p">)</span></span><span id="LC2" class="line"><span class="n">CeNetOmnibus</span><span class="p">()</span></span></pre></div></div>')
#                              
#                          )
#                      ),
#                      h2("1. Data Input",style='font-family:Georgia'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML("<p style='font-size:20px;'><strong>Data input</strong> provides the interface for users to upload data for the construction of ceRNA network.</p>"),
#                              h3("1.1 Expression Profiles"),
#                              HTML("<p style='font-size:20px;'>The expression profiles of ceRNAs and microRNAs should be plain text delimited by tab, comma, space, semicolon or any other prac-ticable marks. Users can set seperators, quotes, with/without headers. To name the datasets, please confirm if the program should name dataset with/without the first column. The rows of uploaded files should represent ceRNAs/microRNAs, while the columns should represent samples.</p>"),
#                              HTML("<b style='font-size:20px;'>CeRNA Expression Profile Samples</b>"),
#                              HTML("<table>
# <thead>
# <tr>
# <th></th>
# <th>TCGA.3C.AAAU.01</th>
# <th>TCGA.3C.AALI.01</th>
# <th>TCGA.3C.AALJ.01</th>
# <th>TCGA.3C.AALK.01</th>
# <th>TCGA.4H.AAAK.01</th>
# </tr>
# </thead>
# <tbody>
# <tr>
# <td>ENSG00000275454</td>
# <td>0.35</td>
# <td>0.13</td>
# <td>0.25</td>
# <td>0.23</td>
# <td>0.2</td>
# </tr>
# <tr>
# <td>ENSG00000261519</td>
# <td>0.06</td>
# <td>0.04</td>
# <td>0.07</td>
# <td>0.01</td>
# <td>0.09</td>
# </tr>
# <tr>
# <td>ENSG00000267405</td>
# <td>0.03</td>
# <td>0.18</td>
# <td>0.15</td>
# <td>0.13</td>
# <td>0</td>
# </tr>
# <tr>
# <td>ENSG00000115365</td>
# <td>25.05</td>
# <td>9.96</td>
# <td>8.47</td>
# <td>11.39</td>
# <td>15.6</td>
# </tr>
# <tr>
# <td>ENSG00000274395</td>
# <td>0.05</td>
# <td>0</td>
# <td>0.09</td>
# <td>0.13</td>
# <td>0.42</td>
# </tr>
# <tr>
# <td>ENSG00000177272</td>
# <td>0.13</td>
# <td>0.49</td>
# <td>0.22</td>
# <td>0.33</td>
# <td>0.13</td>
# </tr>
# <tr>
# <td>ENSG00000235142</td>
# <td>0.05</td>
# <td>0.01</td>
# <td>0.03</td>
# <td>0.03</td>
# <td>0</td>
# </tr>
# </tbody>
# </table>"),
#                              HTML("
#                                   <b style='font-size:20px;'>CeRNA Expression Profile Samples</b>
#                                   <table style='font-size:20px;'><thead><tr><th>mirbase21_ID</th><th>TCGA.BH.AB28.01</th><th>TCGA.AO.A128.01</th><th>TCGA.A1.A0SD.01</th><th>TCGA.B6.A0I1.01</th><th>TCGA.BH.A0BF.01</th></tr></thead><tbody><tr><td>MIMAT0002841</td><td>0.745546</td><td>0</td><td>0.253132</td><td>0</td><td>0</td></tr><tr><td>MIMAT0002840</td><td>0.186387</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
# <tr>
# <td>MIMAT0021122</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# </tr>
# <tr>
# <td>MIMAT0021123</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# </tr>
# <tr>
# <td>MIMAT0021120</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# </tr>
# <tr>
# <td>MIMAT0021121</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# <td>0</td>
# </tr>
# </tbody>
# </table>
#                                   "),
#                              HTML("<blockquote><p>NOTE: Please Remeber to Click <strong>Preview</strong> Button on the right-bottom corner of the panel once set parameters properly.</p></blockquote>"),
#                              h3("1.2 The Interaction between ceRNAs and microRNAs"),
#                              HTML('<p style="font-size:20px;">The interactions file between ceRNAs and microRNAs should be 0-1 matrix to represent if there are interactions between ceRNAs and microRNAs. The file should be plain text delimited by tab, comma, space, semicolon or any other prac-ticable marks. Users can set seperators, quotes, with/without headers. To name the datasets, please confirm if the program should name dataset with/without the first column. The rows of uploaded files should represent ceRNAs, while the columns should represent microRNAs.</p>'),
#                              HTML("
#                                   <b style='font-size:20px;'>CeRNA Expression Profile Samples</b>
#                                   <table>
# <thead>
# <tr>
# <th></th>
# <th>MIMAT0000646</th>
# <th>MIMAT0002809</th>
# <th>MIMAT0000617</th>
# <th>MIMAT0000266</th>
# <th>MIMAT0000264</th>
# <th>MIMAT0000263</th>
# <th>MIMAT0000261</th>
# <th>MIMAT0005951</th>
# <th>MIMAT0000278</th>
# </tr>
# </thead>
# <tbody>
# <tr>
# <td>ENSG00000275454</td>
# <td>1</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# </tr>
# <tr>
# <td>ENSG00000261519</td>
# <td>1</td>
# <td>0</td>
# <td>0</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>0</td>
# </tr>
# <tr>
# <td>ENSG00000267405</td>
# <td>0</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>0</td>
# <td>0</td>
# </tr>
# <tr>
# <td>ENSG00000115365</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# </tr>
# <tr>
# <td>ENSG00000274395</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# </tr>
# <tr>
# <td>ENSG00000177272</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>0</td>
# <td>1</td>
# </tr>
# <tr>
# <td>ENSG00000235142</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# <td>1</td>
# </tr>
# </tbody>
# </table>
#                                   "),
#                              
#                              HTML('<blockquote><p>NOTE: Please Remeber to Click <strong>Preview</strong> Button on the right-bottom corner of the panel once set parameters properly.</p></blockquote>'),
#                              h3('1.3 Essential ceRNA Information'),
#                              HTML('<p style="font-size:20px;">The Enssential ceRNA Information will be used to group ceRNAs and set network/module visualization</p>'),
#                              HTML('<p style="font-size:20px;">The Essential ceRNA Information can be supplied by two ways:</p>'),
#                              HTML('<ul style="font-size:20px;"><li><p><strong>Biomart Download</strong></p></li><li><p><strong>Custom Upload</strong></p></li></ul>'),
#                              HTML('<p style="font-size:20px;">For <strong>Biomart Download</strong> method, users can select Ensembl Archieve, Species, Gene ID Type, and search items in the Ensembl Database. Users are able to select a part of ceRNAs in the input datasets.</p>'),
#                              HTML('<p style="font-size:20px;">For <strong>Custom Upload</strong> method, the uploaded file should be plain text delimited by tab, comma, space, semicolon or any other prac-ticable marks. Users can set seperators, quotes, with/without headers. To name the datasets, please confirm if the program should name dataset with/without the first column. The rows of uploaded files should represent ceRNAs, while the columns should represent the information of ceRNAs. The first column of the uploaded file should be the ceRNA identifiers.</p>'),
#                              HTML("
#                                   <b style='font-size:20px;'>CeRNA Information Samples</b>
#                                   <table>
# <thead>
# <tr>
# <th></th>
# <th>ensembl_gene_id</th>
# <th>description</th>
# <th>strand</th>
# <th>external_gene_name</th>
# <th>gene_biotype</th>
# </tr>
# </thead>
# <tbody>
# <tr>
# <td>ENSG00000006377</td>
# <td>ENSG00000006377</td>
# <td>distal-less homeobox 6 [Source:HGNC Symbol;Acc:HGNC:2919]</td>
# <td>1</td>
# <td>DLX6</td>
# <td>protein_coding</td>
# </tr>
# <tr>
# <td>ENSG00000010361</td>
# <td>ENSG00000010361</td>
# <td>fuzzy planar cell polarity protein [Source:HGNC Symbol;Acc:HGNC:26219]</td>
# <td>-1</td>
# <td>FUZ</td>
# <td>protein_coding</td>
# </tr>
# <tr>
# <td>ENSG00000010438</td>
# <td>ENSG00000010438</td>
# <td>serine protease 3 [Source:HGNC Symbol;Acc:HGNC:9486]</td>
# <td>1</td>
# <td>PRSS3</td>
# <td>protein_coding</td>
# </tr>
# <tr>
# <td>ENSG00000036054</td>
# <td>ENSG00000036054</td>
# <td>TBC1 domain family member 23 [Source:HGNC Symbol;Acc:HGNC:25622]</td>
# <td>1</td>
# <td>TBC1D23</td>
# <td>protein_coding</td>
# </tr>
# <tr>
# <td>ENSG00000047249</td>
# <td>ENSG00000047249</td>
# <td>ATPase H+ transporting V1 subunit H [Source:HGNC Symbol;Acc:HGNC:18303]</td>
# <td>-1</td>
# <td>ATP6V1H</td>
# <td>protein_coding</td>
# </tr>
# <tr>
# <td>ENSG00000056998</td>
# <td>ENSG00000056998</td>
# <td>glycogenin 2 [Source:HGNC Symbol;Acc:HGNC:4700]</td>
# <td>1</td>
# <td>GYG2</td>
# <td>protein_coding.</td>
# </tr>
# </tbody>
# </table>
#                                   "),
#                              
#                              HTML('<blockquote><p>NOTE: Please Remeber to Click <strong>Preview</strong> Button on the right-bottom corner of the panel once set parameters properly.</p></blockquote>'),
#                              HTML('<blockquote><p>WARNING: The Biomart Download may take relatively longer time, especially for the users on the Chinese Mainland.</p></blockquote>')
#                              
#                          )
#                      ),
#                      h2('2. Data Processing'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML('
#                              <p style="font-size:20px;"><strong>Data Processing</strong>  provide the interface to <em>Group CeRNAs</em>, <em>Filter Bad Samples</em>, <em>Filter Non-Expressed MicroRNAs/CeRNAs</em> and <em>Value Transformation</em>.</p>
#                                 <p style="font-size:20px;">When enter the <strong>Data Processing</strong> tab, the program will obtains the common ceRNAs, microRNAs and samples in the uploaded  files.</p>'),
#                              HTML("<p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/Valid_Gene.png' alt='' style='max-width:100%;'></p>"),
#                              h3('2.1 Gene Grouping'),
#                              HTML("
#                                 <p style='font-size:20px;'>Users are allowed to group ceRNAs into different groups to set different paramenters for the ceRNA filter and network construction. For example, the non-coding RNAs, especially long non-coding RNAs (lncRNAs)  usually have relatively lower expression levels. The thresh of non-expressed lncRNAs may be lower than that of mRNAs.</p>
#                                 <p style='font-size:20px;'>Users can group ceRNAs according to the essential ceRNA information uploaded in step 1.3.  Validated columns are listed.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/Gene_Mapping_1.jpg' alt='' style='max-width:100%;'></p>
#                                 <blockquote><p>NOTE: Click <strong>Preview</strong> Button on the right-bottom corner of the panel once set parameters properly.</p></blockquote>
#                                 <blockquote><p>NOTE: The ceRNAs of non-selected items will be removed in the next processing.</p></blockquote>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/Group_statistic.svg' alt='' style='max-width:100%;'></p>
#                                 "),
#                              h3('2.2 Sample Filter'),
#                              HTML("
#                                 <p style='font-size:20px;'>There may be some bad samples in the ceRNA/microRNA expression profiles. This section allows users to remove these bad samples.</p>
#                                 <p style='font-size:20px;'>Firstly, users should set the thresh of a good microRNA/ceRNA in samples. For example, we think the CPM of a microRNA larger than 50 is good, while the RPKM of a ceRNA larger than 0.1 is good. Then, the program will calculate the good microRNAs/ceRNAs ratio each sample, and create the distribution plot. Finally, users need to decide how many samples should be remained by sliding the percentile bar.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/Sample_Filter1.jpg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/microSampleFilter.svg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/RNASampleFilter.svg' alt='' style='max-width:100%;'></p>
#                                 <blockquote><p>NOTE: Click <strong>Preview</strong> to create the plot, and the change of Percentile bar will update the plot.</p></blockquote>
#                                 <blockquote><p>NOTE: Please Remeber to Click <strong>Filter</strong> Button on the right-bottom corner of the panel once set parameters properly to execute the Sample Filter.</p></blockquote>
#                                 "),
#                              h3('2.3 RNA Filter'),
#                              HTML("
#                                 <p style='font-size:20px;'>Because the expressions of ceRNAs and microRNAs have tissue-specificity, non-expressed microRNAs and ceRNAs should not appear in the ceRNA networks. This section allow users to remove non-expressed microRNAs and ceRNAs.</p>
#                                 <p style='font-size:20px;'>Firstly, users should set the minimal expression thresh of a expressed microRNA or ceRNA . For example, we think the CPM of a microRNA larger than 100 is expressed, while the RPKM of a noncoding ceRNA larger than 0.5 is expressed and 1 for a coding ceRNA. Then, the program will calculate the expressed sample ratio of each RNA, and create the distribution plot. Finally, users need to decide how many samples a RNA  should express in by sliding the Minimal Sample Ratio bar.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/RNA_Filter1.jpg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/microStatistic.svg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/NoncodingStatistic.svg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/CodingStatistic.svg' alt='' style='max-width:100%;'></p>
#                                 <blockquote><p>Tips: Click <strong>Preview</strong> to create the plot, and the change of Percentile bar will update the plot.</p></blockquote>
#                                 <blockquote><p>NOTE: Please Remeber to Click <strong>Filter</strong> Button on the right-bottom corner of the panel once set parameters properly to execute the RNA Filter.</p></blockquote>
#                                 "),
#                              h3('2.4 Value Transformation'),
#                              HTML("
#                                 <p style='font-size:20px;'>We may need to perform some transformation operations on the CeRNA and MicroRNA matrices. In this step, we operate CeRNA by default. You can also choose MicroRNA. Their operation method is the same.</p>
#                                 <p style='font-size:20px;'>In Transform Operations, you can choose to perform log conversion or standardization. Hovering the mouse over each button will introduce detailed processing operations. It should be noted that we only allow log conversion first, or you can ignore the log step and standardize directly. Remember to click the Action button after the operation. If you are not satisfied with the operation, you can click the Cancel button to restore the original data.</p>
#                                 <p style='font-size:20px;'>Note the Custom button. If you want to write a function to perform data conversion, you can click it. There will be detailed examples in the pop-up interface for you to write functions.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/Value_trans1.png' alt='' style='max-width:100%;'></p>
#                                 <blockquote><p>Tips: Our operation will not be iterative. If you click the Action button again, it will perform the operation you selected on the initial data.</p></blockquote>
#                                 ")
#                              
#                          )
#                          
#                      ),
#                      h2('3. Network Construction'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML("
#                                 <p style='font-size:20px;'>CeNet Omnibus  provides a set measurements for users to identify ceRNA pairs and construct ceRNA networks. Current version integrated 5 measurements, including Pearson Correlation Coefficient, liquid association,  microRNA significance, mutual information, conditional mutual information. CeNet Omnibus also allows users to defined new measurements.</p>
#                                 <p style='font-size:20px;'><strong>Network Construction</strong> provide the interface to <em>Choose Measurements</em>, <em>Set Parameters</em> and <em>Construct Network</em>.</p>
#                                 "),
#                              h3('3.1 Choose Measurement'),
#                              HTML("
#                                 <p style='font-size:20px;'>Click <strong>Add New</strong> Button to add a new measurement. Users need to set how many CPU cores ared needed to compute this measurement. Additionally, users can select if they want to compute the measurement of all pairs or a part of pairs according to the ceRNA groups defined in section 2.1.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/add_measurement.jpg' alt='' style='max-width:100%;'></p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/measure_panel.jpg' alt='' style='max-width:100%;'></p>
#                                 <p style='font-size:20px;'>Click Start Btn to  start calculation. When the calculation is finished, the background color will be Green</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/measure_finish.jpg' alt='' style='max-width:100%;'></p>
#                                 <blockquote><p>TIPS: PCC only need one core to compute.</p></blockquote>
#                                 "),
#                              h3('3.2 Set Threshold'),
#                              HTML("
#                                 <p style='font-size:20px;'>When the calculation is finished, the program will create the distribution plot of every task.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/thresh_1.jpg' alt='' style='max-width:100%;'></p>
#                                 <p style='font-size:20px;'><strong>Direction</strong> can set which part of pairs should be remained. <strong>+</strong> and <strong>-</strong> can be used to tune the thresh value with step in <strong>Step</strong></p>
#                                 <p style='font-size:20px;'>After all settings, click <strong>Confirm</strong> button to save the threshes.</p>
#                                 <blockquote><p>Tips: If you want all pairs to share the common thresh, please select <strong>All</strong> in section 3.1. While you want to set every group pair with different threshes,   please select the group pairs seperately.</p></blockquote>
#                                 "),
#                              h3('3.3 Network Construction'),
#                              HTML("
#                                 <p style='font-size:20px;'>After saving all the threshes, Click <strong>Construct Network</strong> button to create the ceRNA network. The program will apply all the threshold setted in section 3.2. The program will summarize the network after the  constrction.</p>
#                                 <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/network_summary.jpg' alt='' style='max-width:100%;'></p>
#                                 ")
#                          )
#                          
#                      ),
#                      h2('4. Network Visualization'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML("
#                                <h3>4.1 Choose Layout</h3>
#                                <p style='font-size:20px;'>We provide seven layouts for you to choose. Including: <em>Circle</em>, <em>Random</em>, <em>Grid</em>, Concentric, <em>Breadth First</em> and <em>Cose</em>.</p>
#                                <blockquote><p>NOTE:  The network needs to be constructed in the third step before selecting the layout.</p></blockquote>
#                                <h3>4.2 Change Gene Name</h3>
#                                <p style='font-size:20px;'>You can choose to change the name tag of the network node. The optional entry is the gene information you provided in section 1.3.</p>
#                                <h3>4.3 Choose Node Color</h3>
#                                <p style='font-size:20px;'>First select the grouping information you are interested in. After the selection, the group names of the nodes under the grouping condition will appear. You can change the color of each group of nodes as will. By default, it changes the color of all nodes.</p>
#                                <h3>4.4 Choose Node Shape</h3>
#                                <p style='font-size:20px;'>Same as the previous step, you can change the shape of each node. We provide eight different shapes, such as Exlipse, Star.</p>
#                                <h3>4.5 Select node</h3>
#                                <p style='font-size:20px;'>First select the group that the node name belongs to, and then enter exactly the information of the node you need to search. If you can't find it, a prompt will pop up. If the search is successful, the node will enter the selected state. The label of the node will show another color. You can move the node by mouse.</p>
#                                <blockquote><p>Tips: Make sure the group you choose matches the one in Change Gene Name</p></blockquote>
#                                <h3>4.6 Reset network</h3>
#                                <p style='font-size:20px;'>Clicking this button will restore the location of the network to prevent mouse misoperations from moving the network out of the window. Note that this button only restores the location of the network. The color, shape, etc. will not change.</p>
#                                <h3>4.7 Export Network</h3>
#                                <p style='font-size:20px;'>Export the visualized network in the fourth page as a image</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/network_visual.png' alt='' style='max-width:100%;'></p>
#                                 
#                                ")
#                          )
#                          
#                      ),
#                      h2('5. Network Analysis'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML("
#                                <p style='font-size:20px;'>CeNet Omnibus provide four types of analysis to ceRNA network, including <strong>Network Topological Property</strong>, <strong>Network Module</strong>, <strong>Enrichment Analysis</strong> and <strong>Survival Analysis</strong>.</p>
#                                
#                                <h3>5.1 Network Topological Property</h3>
#                                <p style='font-size:20px;'>CeNet Omnibus can calculate four node centralities and one edge centrality to evaluate the network topological properties. Users only need to click the corresponding buttons to create the density plot of every centrality.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/centrality1.jpg' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/degree.jpg' alt='' style='max-width:100%;'></p>
#                                <blockquote><p>Tips: Click <strong>Detail</strong> button to get detail information</p></blockquote>
# 
#                                <h3>5.2 Network Module</h3>
#                                <p style='font-size:20px;'>CeNet Omnibus integrated a set of network module detection algorithms to identify ceRNA modules, including Louvain Method, MCL, MCODE, etc.</p>
#                                <p style='font-size:20px;'>CeNet Omnibus will summarize the communities in a table. Users can select modules to visualize and set node properties with the similar way in section 4.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/module_summary.png' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/module1.jpg' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/module2.jpg' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/module3.jpg' alt='' style='max-width:100%;'></p>
# 
#                                <h3>5.3 Enrichment Analysis</h3>
#                                <p style='font-size:20px;'>Here we can perform enrichment analysis to these modules. Sure, you can also analyze other genes sets, by choosing <strong>Gene Set Source</strong> as <strong>Custom Gene</strong> and inputing data as required.</p>
#                                <p style='font-size:20px;'>Currently, CeNet Omnibus integrates <strong>g:Profiler</strong> to do function enrichment analysis. Besides, CeNet Omnibus allows users to provide custom defined gene sets to other analysis. For user-defined data sets,  users should choose <strong>custom input</strong>, and upload a gene sets file. In this file, every line represents a gene set, seperated with tab. And the first element in every line should be the name of the gene set. Users can click <strong>Preview</strong> to check the uploaded file. The results will be shown in the <strong>Custom Gene Preview</strong> panel. Users can click <strong>Details</strong> button to view genes in corresponding gene sets.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/hallmark.png' alt='' style='max-width:100%;'></p>
#                                <p style='font-size:20px;'>The following is the parameter introduction:</p>
#                                <p style='font-size:20px;'><strong>Organism</strong>: Select species for input data.</p>
#                                <p style='font-size:20px;'><strong>Gene ID Map</strong>:Select Gene ID for input data.</p>
#                                <p style='font-size:20px;'><strong>Significance threshold</strong>: Select enrichment calculation method.</p>
#                                <p style='font-size:20px;'><strong>Data Sources</strong>:choose the data sources of interest(See R package: gprofiler2 for more details)</p>
#                                <p style='font-size:20px;'><strong>User threshold</strong>:defines a custom p-value significance threshold for the results.</p>
#                                <p style='font-size:20px;'><strong>Module analysis</strong>:Choose which modules to analyze.</p>
#                                <p style='font-size:20px;'><strong>Plot Type</strong>:Select the type of picture to display.</p>
#                                <p style='font-size:20px;'>You should confirm all parameter Meet your requirements. Finally click <strong>Perform</strong> Button. You will see pictures.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/bar_Module0_enrichment_plot_GO_BP.svg' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/point_Module0_enrichment_plot_GO_BP.svg' alt='' style='max-width:100%;'></p>
#                                <blockquote><p>NOTE: You need to make sure that there are values at the top of the 2nd Step and <strong>Network Modules</strong> on 5th Step have been completed.Otherwise,<strong>Gene ID Map</strong> and <strong>Module analysis</strong> will be empty.</p></blockquote>
# 
#                                <h3>5.4 Survival Analysis</h3>
#                                <p style='font-size:20px;'>CeNet Omnibus provides the interface to perform survival analysis. There are two models, including Kaplan-Meier survival estimate model and Cox proportional hazards regression model.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/survival.jpg' alt='' style='max-width:100%;'></p>
#                                <p style='font-size:20px;'>Users need to upload the clinical information and corresponding expression profiles. Alternatively, the expression profiles can be the expreesion profiles used to construct ceRNA network. The program will obtain the patients that appear in both data sets. Therefore, please make sure the patient ids are in the same format in two data sets.</p>
#                                <p style='font-size:20px;'>Users need to set parameters for the estimation models. CeNet Omnibus can analyze survival hazard of gene set or single gene.</p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/km_curve.svg' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/km_group.png' alt='' style='max-width:100%;'></p>
#                                <p><img src='https://gitee.com/nbbcq/ceNet-Omnibus/raw/master/Figures/cox_table.jpg' alt='' style='max-width:100%;'></p>
#                                
# 
#                                ")
#                          )
#                          
#                      ),
#                      h2('Download'),
#                      div(class="box box-solid box-primary",
#                          div(class="box-header",
#                              h3(class="box-title"),
#                              div(class="box-tools pull-right",
#                                  tags$button(class='btn btn-box-tool',"data-widget"="collapse",
#                                              tags$i(class='fa fa-minus')
#                                  )
#                              )
#                          ),
#                          div(class="box-body",
#                              HTML("
#                                <p style='font-size:20px;'>CeNet Omnibus allows users to download every plot. But, for the plots of enrichment analysis and survival analysis, users should click the Download or Export button <strong>Twice</strong> to download the plots (we have not found the solution to solve this problem). In addition, users need to ensure that the system supports <strong>zip/unzip</strong> command.</p> 
#                                ")
#                          )
#                      )
#                      
#                  )
# )