#Prend en paramètre le dataset des données préparée et avec le passé rempli, et retourne la liste des
#prochaines mesures à calculer.

completeDataset <- function(dataset, steps="month")
{
  startDates <- c()
  endDate <- max(dataset$date)
  for(pointName in unique(dataset$point))
  {
    pointSet <- dataset[which(dataset$point == pointName),]
    startDates <- c(startDates, max(pointSet$date))
  }
  
  startDate <- min(startDates)
  nextDate <- startDate
  
  month(nextDate) <- month(nextDate) + 1
  
  lastSet <- dataset[which(dataset$date==startDate)]
  
  nextSet <- data.frame()
  
  resultSet <- data.frame()
  
  for(row in 1:nrow(lastSet))
  {
    currentSet <- lastSet[row,]
    nextSet <- currentSet
    
    nextSet$date <- nextDate
    
    neighbours <- getneighbours(dataset, nextSet$point)
    
    nextSet$value <- 0
    nextSet$valuePrec1 <- currentSet$value
    nextSet$valuePrec2 <- currentSet$valuePrec1
    
    nextSet$neighbours1value <- dataset[which(dataset$date==nextDate && dataset$point==neighbours[1])]
    nextSet$neighbours1valuePrec1 <- currentSet$neighbours1value
    nextSet$neighbours1valuePrec2 <- currentSet$neighbours1valuePrec1
    
    nextSet$neighbours2value <- dataset[which(dataset$date==nextDate && dataset$point==neighbours[2])]
    nextSet$neighbours2valuePrec1 <- currentSet$neighbours2value
    nextSet$neighbours2valuePrec2 <- currentSet$neighbours2valuePrec1
    
    nextSet$neighbours3value <- dataset[which(dataset$date==nextDate && dataset$point==neighbours[3])]
    nextSet$neighbours3valuePrec1 <- currentSet$neighbours3value
    nextSet$neighbours3valuePrec2 <- currentSet$neighbours3valuePrec1
    
    resultSet <- rbind(resultSet, nextSet)
  }
  
  return(startDate)
}

dist_between_points <- function(x1, y1, x2, y2) {
  tmp <- sqrt(abs((x1 - x2)**2 + (y1 - y2)**2))
  return(tmp)
}

getneighbours = function(dataset, point='point002', numberOfNeighbours=3)
{
  pointsName <- unique(dataset$point)
  
  selectedPointSet <- dataset[which(dataset$point == point),]
  selectedPointX <- selectedPointSet[1,]$x
  selectedPointY <- selectedPointSet[1,]$y
  
  pointsDistances <- data.frame(point = pointsName)
  
  distances <- c()
  
  for(name in pointsName)
  {
    pointSet <- dataset[which(dataset$point == name),]
    pointX <- pointSet[1,]$x
    pointY <- pointSet[1,]$y
    
    distances <- c(distances, dist_between_points(selectedPointX, selectedPointY, pointX, pointY))
  }
  
  pointsDistances$distances <- distances
  
  pointsDistances <- pointsDistances[order(pointsDistances$distances),]
  
  return(pointsDistances[1:3,]$point)
}






