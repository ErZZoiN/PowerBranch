#Prend en paramètre les mesures, et ressort les mesures formatées

trimSet = function(dataset, numberOfMeasure=10)
{
  pointsName <- unique(dataset$point)
  resultSet <- data.frame(point=character(),
                          parameter=character(),
                          date=as.Date(character()),
                          x=double(),
                          y=double(),
                          detectionLimit=double())
  
  for(pointName in pointsName)
  {
    pointSet <- dataset[which(dataset$point==pointName),]
    if(nrow(pointSet)>=numberOfMeasure)
    {
      resultSet <- rbind(resultSet, pointSet)
    }
  }
  
  
  return(resultSet)
}

interpolateTime <- function(dataset, steps="month")
{
  test <- data.frame()
  for(pointName in unique(dataset$point))
  {
    pointSet <- dataset[which(dataset$point==pointName), ]
    startDate <- min(pointSet$date)
    endDate <- max(pointSet$date)
    
    day(startDate) <- 1
    month(startDate) <- month(startDate) + 1
    
    day(endDate) <- 1
    month(endDate) <- month(endDate) + 1
    
    dateSeq <- seq(startDate, endDate, by = steps)
    
    tableOut <- data.frame(time = dateSeq)
    
    tableIn <- data.frame(time = pointSet$date, value = pointSet$detectionLimit)
    
    tableOut <- approx(tableIn$time, tableIn$value, xout = tableOut$time, method="linear")
    
    rowsOut <- data.frame(points=rep(pointName, length(dateSeq)),
                          parameter=rep(dataset$parameter[1], length(dateSeq)),
                          date=as.Date(tableOut$x, origin = "1970-1-1"),
                          value=tableOut$y,
                          x=rep(pointSet$x[1], length(dateSeq)),
                          y=rep(pointSet$y[1], length(dateSeq)))
    
    test <- rbind(test, rowsOut)
  }
  
  return(test)
}

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
  
  write.csv(resultSet, fp, na="", row.names = FALSE)
  
  return(resultSet)
}

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

prepPoint = function(dataset, point, minMeasures=5, nbrOfNeighbours=3, mesuresInBetween=2)
{
  dataset$date <- as.Date(dataset$date, format = "%m/%d/%Y")
  dataset <- getDistances(dataset = dataset, point=point, numberOfNeighbours = nbrOfNeighbours)
  dataset <- interpolateTime(dataset = dataset)
  dataset <- ArrangeData(dataset = dataset, point = point)
  
  return(dataset)
}

prepData = function(dataset, minMeasures=5, nbrOfNeighbours=3, mesuresInBetween=2)
{
  dataset <- trimSet(dataset=dataset, numberOfMeasure = minMeasures)
  resultSet <- data.frame(point=character(),
                          parameter=character(),
                          date=as.Date(character()),
                          x=double(),
                          y=double(),
                          detectionLimit=double())
  
  pointsName <- unique(dataset$point)
  
  first<-TRUE
  for(point in pointsName)
  {
    str(point)
    if(first)
    {
      resultSet <- prepPoint(dataset, point, minMeasures, nbrOfNeighbours, mesuresInBetween)
      
      first<-FALSE
    }
    else
    {
      resultSet <- rbind(resultSet, prepPoint(dataset, point, minMeasures, nbrOfNeighbours, mesuresInBetween))
    }
  }
  
  return(resultSet)
}



