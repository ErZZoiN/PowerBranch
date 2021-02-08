ArrangeData = function(dataset, point, steps="month")
{
  resultSet <- dataset[which(dataset$points==point),]
  resultSet <- addPrecValues(resultSet)
  
  for(row in 1:nrow(resultSet))
  {
    currentDate <- resultSet[row, "date"]
    
    i <- 1
    for(pointName in unique(dataset$point))
    {
      if(pointName != point)
      {
        neighboursSet <- dataset[which(dataset$points == pointName),]
        neighboursSet <- addPrecValues(neighboursSet)
        
        neighboursName <- paste('neighbours', i, 'value', sep="")
        neighboursNamePrec1 <- paste(neighboursName, 'Prec1', sep="")
        neighboursNamePrec2 <- paste(neighboursName, 'Prec2', sep="")
        
        if(nrow(neighboursSet[which(neighboursSet$date == currentDate),])==1)
        {
          neighboursRow <- neighboursSet[which(neighboursSet$date == currentDate),]
          resultSet[which(resultSet$date == currentDate),neighboursName] <- neighboursRow$value
          resultSet[which(resultSet$date == currentDate),neighboursNamePrec1] <- neighboursRow$valuePrec1
          resultSet[which(resultSet$date == currentDate),neighboursNamePrec2] <- neighboursRow$valuePrec2
          
        }
        else
        {
          resultSet[which(resultSet$date == currentDate),neighboursName] <- NA
          resultSet[which(resultSet$date == currentDate),neighboursNamePrec1] <- NA
          resultSet[which(resultSet$date == currentDate),neighboursNamePrec2] <- NA
        }
        
        i <- i+1
      }
    }
    
  }
  
  fp <- paste("L:\\KRIGIS\\MachineLearning\\ParameterMesures\\MercuryPointSets\\", point, ".csv", sep="")
  
  write.csv(resultSet, fp, na="")
  
  return(resultSet)
}
