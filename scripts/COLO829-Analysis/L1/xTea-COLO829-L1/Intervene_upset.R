#!/usr/bin/env Rscript
if (suppressMessages(!require("UpSetR"))) suppressMessages(install.packages("UpSetR", repos="http://cran.us.r-project.org"))
library("UpSetR")
pdf("/n/data1/bch/genetics/lee/projects/SMaHT/scripts/COLO829-Analysis/L1/xTea-COLO829-L1/Intervene_upset.pdf", width=14, height=8, onefile=FALSE, useDingbats=FALSE)
expressionInput <- c('xTea-COLO829T_LINE1'=56,'xTea-COLO829BL_LINE1'=53,'xTea-COLO829BL_LINE1&xTea-COLO829T_LINE1'=199)
upset(fromExpression(expressionInput), nsets=2, nintersects=30, show.numbers="yes", main.bar.color="#ea5d4e", sets.bar.color="#317eab", empty.intersections=NULL, order.by = "freq", number.angles = 0, mainbar.y.label ="No. of Intersections", sets.x.label ="Set size")
invisible(dev.off())
