addPrecValues = function(dataset, mesuresInBetween=2)
{
  #On considère que le dataset contient les mesures d'un unique point
  
  
  dataset <- dataset[order(dataset$date),]
  
  translatedValues1 <- c(NA, dataset$value)
  translatedValues1 <- head(translatedValues1, -1)
  translatedValues2 <- c(NA, NA, dataset$value)
  translatedValues2 <- head(translatedValues2, -2)
  
  dataset$valuePrec1 <- translatedValues1
  dataset$valuePrec2 <- translatedValues2
  
  return(dataset)
}