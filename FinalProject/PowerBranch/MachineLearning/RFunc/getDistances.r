dist_between_points <- function(x1, y1, x2, y2) {
  tmp <- sqrt(abs((x1 - x2)**2 + (y1 - y2)**2))
  return(tmp)
}

getDistances = function(dataset, point='point002', numberOfNeighbours=3)
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
  
  i<-2
  
  resultSet <- dataset[which(dataset$point==pointsDistances$point[1]),]
  
  while(i<=numberOfNeighbours+1)
  {
    pointSet <- dataset[which(dataset$point==pointsDistances$point[i]),]
    resultSet <- rbind(resultSet, pointSet)
    i<-i+1
  }
  
  return(resultSet)
}