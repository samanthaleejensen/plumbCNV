
suffix <- 1
metabo <- F
plumber <- T
dgv.valid <- F
samp.excl <- F
eval <- F
my.st <- 6
my.end <- 6
do.cnv <- T
comp <- F
samp.set <- "light"
pca.set <- 12
restore <- F
sex.correct <- F
q.cores <- 100 #NA
hmm.file <- "/chiswick/data/ncooper/ImmunochipFamilies/ANNOTATION/hh0+.hmm"

library(reader); library(bigpca); library(NCmisc)
#source("/chiswick/data/ncooper/ImmunochipReplication/Scripts/FunctionsCNVAnalysis.R")
source("~/github/plumbCNV/FunctionsCNVAnalysis.R")
load.all.libs()
#source("~/github/plumbCNV/geneticsFunctions.R")



#plumbCNV(dir.raw="/ipswich/data/Immunochip/FinalReports/",
#         dir.base="/chiswick/data/ncooper/ImmunochipReplication/",



auxdirI <- "~/Documents/necessaryfilesCBR" # create this dir and copy a file.spec, and the snpNames.txt
dir_rawI <- "/sopworth/data/illumina/hui/cbrmicro/cbr4k8k/"
dir_baseI <- "/chiswick/data/ncooper/CBR"
s.supI <- "/sopworth/data/illumina/hui/cbrmicro/cbr4k8k/cbr4k8k_FinalReport.txt" # get support from gs-file
gsfI <- T

##############
## SETTINGS ##
##############

#chip.settings <- list(dir.raw=dir_rawI,dir.base=dir_baseI,snp.support=s.supI,
#                      gsf=gsfI,aux.files.dir=auxdirI)
chip.settings <- list(dir.raw=dir_rawI,dir.base=dir_baseI,snp.support=s.supI,
                      gsf=gsfI,aux.files.dir=auxdirI)


base.settings <- list(dt.name="datatracker",
                      delete.as.we.go=F,big.lrr="LRR.dsc",big.baf="BAF.dsc",
                      grps=c(1),snp.fields=NULL,geno.file=NULL,
                      run.mode=c("scratch","normal","big")[1],
                      snp.run.mode=c("normal","skip","plink")[1],
                      manual.col.nums=NULL,plink.imp=F,fet.analysis.p=0.05,HD.mode=F,
                      n.cores=22,low.ram=F,
                      hide.penn.plink=T,penn.path="/usr/local/bin/penncnv64/",
                      build="hg18",erase.previous=F,verbose=F)


penn.settings <- list(hmm=hmm.file,relative=F,run.manual=F,print.cmds=F,q.cores=q.cores,
                      grid.id="all.q",cluster.fn="q.cmd",use.penn.gc=F)



if(comp) {
  snp.settings <- list(callrate.samp.thr=.94,callrate.snp.thr=.985,hwe.thr=0.0001,
                       snp.grp.miss=T,grp.hwe.z.thr=4,grp.cr.thr=.001,het.lo=.17,het.hi=.25)
} else {
  snp.settings <- list(callrate.samp.thr=.94,callrate.snp.thr=.95,hwe.thr=0.000000001,
                       snp.grp.miss=F,grp.hwe.z.thr=400,grp.cr.thr=10^-20,het.lo=.1,het.hi=.40)
}


if(samp.set=="none") {
  samp.settings <- list(nSD=99,mean.thr=c(NA,NA),dlrs.thr=c(NA,NA),gc.thr=c(NA,NA),
                        badPlateThresh=0.99,skip.chr.ab=T,lob=2,hib=2.5,pctile.bound=0.01,cohort.pc.correct=F,
                        batch="plate",other.batch=list(),
                        lrr.report=T,chr.ab.report=T,plate.report=T)
} else {
  if(samp.set=="light") {
    
    samp.settings <- list(nSD=3.5,mean.thr=c("-3.5SD","+3.5SD"),dlrs.thr=c(NA,"+3.5SD"),gc.thr=c("-3.5SD","+3.5SD"),
                          badPlateThresh=0.40,skip.chr.ab=F,lob=2.5,hib=3,pctile.bound=0.01,cohort.pc.correct=F,
                          batch="plate",other.batch=list(),
                          lrr.report=T,chr.ab.report=T,plate.report=T)
  } else {
    #heavy
    samp.settings <- list(nSD=3,mean.thr=c("LB","UB"),dlrs.thr=c(NA,"UB"),gc.thr=c("LB","UB"),
                          badPlateThresh=0.30,skip.chr.ab=F,lob=2,hib=2.5,pctile.bound=0.01,cohort.pc.correct=F,
                          batch="plate",other.batch=list(),
                          lrr.report=T,chr.ab.report=T,plate.report=T)
  }
}




if(pca.set==0) {
  pca.settings <- list(num.pcs=0,pc.to.keep=.20,assoc=F,n.store=50,correct.sex=sex.correct,
                       add.int=F,preserve.median=F,
                       comparison=F,comp.gc=F,comps="plate",exclude.bad.reg=F)
} else {
  if(pca.set==12) {
    
    pca.settings <- list(num.pcs=12,pc.to.keep=.15,assoc=F,n.store=20,correct.sex=sex.correct,
                         add.int=F,preserve.median=F,
                         comparison=T,comp.gc=T,comps="plate",exclude.bad.reg=T)
  } else {
    #24
    pca.settings <- list(num.pcs=24,pc.to.keep=.30,assoc=F,n.store=50,correct.sex=sex.correct,
                         add.int=F,preserve.median=F,
                         comparison=T,comp.gc=T,comps="plate",exclude.bad.reg=T)
  }
}



if(!do.cnv) {
  #none
  cnv.settings <- list(out.format="Ranges",results="everything",print.summary.overlaps=T,
                       cnv.qc=F,rare.qc=F,plate.qc=F,pval=0.01,del.rate=2,dup.rate=2,thr.sd=5,plate.thr=5,
                       rmv.low.plates=F,min.sites=4,rare.olp=0.5,rare.pc=0.03,rmv.bad.reg=T)
} else {
  #normal   # RARE  del.rate=0.4,dup.rate=0.2
  cnv.settings <- list(out.format="Ranges",results="everything",print.summary.overlaps=T,
                       cnv.qc=T,rare.qc=T,plate.qc=T,pval=0.01,del.rate=0.6,dup.rate=0.75,thr.sd=3.5,plate.thr=2.5,
                       rmv.low.plates=F,min.sites=6,rare.olp=0.5,rare.pc=0.05,rmv.bad.reg=T)
}

settings <- c(chip.settings,base.settings,snp.settings,samp.settings,pca.settings,penn.settings,cnv.settings)

###################


dir <- make.dir("/chiswick/data/ncooper/CBR/")


if(plumber) {
  cnvResult <- plumbcnv(settings,start.at=my.st,pause.after=my.end,restore.mode=restore,
                        result.pref=suffix)
  save(cnvResult,file=cat.path(dir$res,"fullresult",suf=suffix,ext="RData"))
}

# test 100kb overlaps

big.summary <- do.CNV.all.overlaps.summary(cnvResult[[1]],dir,comps=c(4:5),dbs=1:3,len.lo=1000, len.hi=5000000,min.sites=6,n.cores=1)
print(pheno.ratios.table(dir,sum.table=summary.counts.table(big.summary)))
DT <- read.data.tracker(dir)
qs.results <- process.quality.scores(DT,suffix,dir,n.pcs=pca.set)
final.tables <- compile.qs.results.to.cc.toptable(qs.results,dir,suffix,cnvResult)

LL <- c(0,10000,50000,100000,200000,300000,400000,500000,1000000,2000000,3000000,4000000)
# test case:controls for different length and QS thresholds

LL <- c(0,1000*c(200,2000))
LLB <- c(LL[-1],250000000)
 
length.analysis.suf(LL,dir,cnvResult,suffix,thr.col="score",cnts=c(9238,6524),upper.thr=LLB)

oo1 <- extract.cnv.regions(dir,type="del",by.cnv=F,lwr=0.25,upr=4,FET=T,prt=F)
oo1 <- super.annotate.cnvs(oo1,hap=TRUE)


#length.analysis(LL,dir,cnvResult,suffix,del.thr=.95,dup.thr=.75)

#plot.all.samples.for.cnv(dir,reg="S78",dup=F,suffix="1")




if(eval) {
  #source("validationWorking.R")
  do.plots <- F # don't redo fp/fn plots each time
  do.metabo <- F  # don't redo the metabochip analysis each time
  do.qs <- T
  plot.range <- 1:20
  min.snps <- 6
  print.common <- F
  ind.examples <- F
  n.pcs <- pca.set; n.pcs2 <- NA
  suffix <- suffix
  dir2 <- make.dir("/chiswick/data/ncooper/metabochipRunTest/")
  if(metabo) { source("~/github/plumbCNV/personal/metabochip.validation.R") }
  from.scratch <- F  # first time only set to T, otherwise F
  suffix <- suffix
  validate <- T
  dir <- make.dir("/chiswick/data/ncooper/immunochipRunTwo/")
  DT <- read.data.tracker(dir)
  thr <- .95
  n.cores <- 1
  if(dgv.valid) { source("~/github/plumbCNV/personal/create.dgv.validation.set.for.ichip.R") }
}
