setwd("L:/KRIGIS/Krigis/Backend/ContaminationPrediction/MachineLearning")

library(stringr)
library(stringi)
library(lubridate)

dataset <- read.csv(file = "./MercuryReadyForFilling.csv")
dataset$date <- as.Date(dataset$date)
dataset <- dataset[which(dataset$date>as.Date("2013-12-30")),]
write.csv(x = dataset, file = "./PredictedData.csv", row.names = FALSE)