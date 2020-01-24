#Multiple imputation
#Missing gestational age on 71 births and pre-pregnancy body mass index on 536 pregnancies
library(mice)
library(VIM)
set.seed(897)

#Look at pattern of missingness
md.pattern(dat)
md.pairs(dat)
aggr_plot <- aggr(dat, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data), cex.axis=.7, gap=3, ylab=c("Histogram of missing data","Pattern"))

#Remove gestational age centered and squared because don't want to include them in imputation model
dat<- dplyr::select(dat, -c("gest_agec",  "gest_agec2"))

#Initialize MICE
init <- mice(dat, maxit = 0)
meth <- init$method
predM <- init$predictorMatrix

#Remove additional variables from imputation
predM[, c("StudyID_kid", "StudyID_mother", "mom_agec", "mom_agec2", "induced", "mom_PC_or_Non_PC", "County", "HBP", "CSD2000", "y910", "any_sleep", "season", "cluster")]=0

#Set another method and say which type of variable you're imputing
meth[c("ppbmi")] <- "polr" 
meth[c("gestational_age")] <- "norm" 
meth[c("y")] <- "norm" 

post <- make.post(dat)
post["gestational_age"] <-
  "imp[[j]][, i] <- squeeze(imp[[j]][, i], c(22, 43))"

#30 imputations
imputed2 <- mice(dat, method=meth, predictorMatrix=predM, m=30, seed=103, post = post)

tiff(filename = "Imputed_gestage_Distribution.tiff", type = "cairo" ,  res=300, height = 4.5, width = 4.5, units = "in")
densityplot(imputed, data= ~ gestational_age, xlab="Gestational age (weeks)", fontsize=10)
dev.off()
tiff(filename = "Imputed_BMI_Distribution.tiff", type = "cairo" ,  res=300, height = 4.5, width = 4.5, units = "in")
densityplot(imputed, data= ~ ppbmi, xlab = "Pre-pregnancy BMI category")
dev.off()

#Running model, there is an easier way if you don't need to bootstrap like I do
#I am running causal mediation analyses
boot_data_ptb <- list() 

for (i in 1:30) {
  print(i)
  
  datcc <- complete(imputed,i)
  #Do this 30 times
  datcc <- dplyr::select(datcc, c("y" , "a" , "mom_agec" , "mom_agec2" , "black" , "hispan" , 
                                  "MA" , "smok_stat" , "mom_PC" , "ppbmi" , "CSDq" ,  "muni_water" ,  
                                  "nulpar" , "mean5p" ,  "GMC" ,  "concept_season" , "y910", "dist2roadq", "cluster"))
  datcc$y <- as.numeric(datcc$y == 1)
  datcc <- filter(datcc, MA==0)
  
  #1 Data
  
  #5 Mediator model
  mmodel <- "a ~ mom_agec + mom_agec2 + black + hispan+ smok_stat + mom_PC + ppbmi + CSDq +  muni_water  + dist2roadq +  nulpar + mean5p +  GMC +  concept_season + y910"
  
  #6 Outcome model for preterm birth
  ymodel <- "y ~ a + mom_agec + mom_agec2 + black + hispan  + smok_stat + mom_PC + ppbmi + CSDq +  muni_water  + dist2roadq +  nulpar + mean5p +  GMC +  concept_season + y910"
  
  #7 Covariates to marginalize over
  qmodel <- "mom_agec + mom_agec2 + black + hispan  + smok_stat + mom_PC + ppbmi + CSDq +  muni_water  +  nulpar + mean5p +  GMC +   y910 + concept_season + dist2roadq"
  
  cov <- c("mom_agec", "mom_agec2", "black", "hispan", "smok_stat",  "muni_water", "mean5p", "CSDq", "nulpar", "ppbmi", "mom_PC",  "GMC", "y910", "concept_season", "dist2roadq")
  
  #point estimate
  tmle <- vtmle(outcome="y",mediator="a", obsdat=datcc, ymodel=ymodel, mmodel=mmodel)
  
  # run bootstrap
  b_results <- lapply(1:250, function(x) clusterboot(x, outcome="y", mediator="a", obsdat="datcc", clusterid="cluster",ymodel=ymodel, mmodel=mmodel)) 
  
  b_df <- do.call(rbind, b_results)
  
  boot_data_ptb[[i]] <- data.frame(cbind(rd = tmle, var = var(b_df)))
  
}

#Final result
boot_data_ptb_b <- do.call(rbind, boot_data_ptb)






