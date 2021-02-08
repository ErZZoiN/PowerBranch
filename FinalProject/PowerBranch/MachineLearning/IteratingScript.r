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

getEmptyPoints <- function(prevSet, nextSet)
{
  res <- c()
  for(pointName1 in unique(prevSet$point))
  {
    
    isFound <- FALSE
    for(pointName2 in unique(nextSet$point))
    {
      if(pointName2==pointName1)
      {
        isFound <- TRUE
      }
    }
    
    if(!isFound)
    {
      res <- c(res, pointName1)
    }
  }
  
  return(res)
}

fillPast <- function(dataset, steps="month")
{
  beginDate <- min(dataset$date)
  
  for(pointName in unique(dataset$point))
  {
    str(pointName)
    
    pointSet <- dataset[which(dataset$point == pointName),]
    earliestDate <- min(pointSet$date)
    earliestSet <- pointSet[which(pointSet$date == earliestDate),]
    
    while(earliestDate>beginDate)
    {
      month(earliestDate) <- month(earliestDate) - 1
      earliestSet$date <- earliestDate
      
      dataset <- rbind(dataset, earliestSet)
    }
  }
  
  return(dataset)
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
    #str(point)
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



PrepForPrediction = function(dataset, minMeasures=5, nbrOfNeighbours=3, mesuresInBetween=2)
{
  dataset <- trimSet(dataset=dataset, numberOfMeasure = minMeasures)
  dataset <- interpolateTime(dataset = dataset)
  dataset <- dataset[which(!is.na(dataset$value)),]
  dataset <- fillPast(dataset)
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
  
  return(pointsDistances[2:4,]$point)
}

NextDataset <- function(dataset, steps="month")
{ 
  
  dataset$date <- as.Date(dataset$date)
  startDates <- c()
  endDate <- max(dataset$date)
  for(pointName in unique(dataset$point))
  {
    pointSet <- dataset[which(dataset$point == pointName),]
    startDates <- c(startDates, max(pointSet$date))
  }
  
  startDate <- min(as.Date(startDates, origin = "1970-01-01"))
  nextDate <- startDate
  
  month(nextDate) <- month(nextDate) + 1
  
  nextSet <- data.frame()
  
  dataset <- addNeighboursValues(dataset, startDate)
  
  lastSet <- dataset[which(dataset$date==startDate),]
  
  resultSet <- data.frame()
  
  newPoints <- getEmptyPoints(dataset[which(dataset$date==startDate),],dataset[which(dataset$date==nextDate),])
  
  for(pointName in newPoints)
  {
    currentSet <- lastSet[which(lastSet$point==pointName),]
    nextSet <- currentSet
    
    nextSet$date <- nextDate
    
    neighbours <- getneighbours(dataset, nextSet$point)
    
    nextSet$value <- 0
    nextSet$valuePrec1 <- currentSet$value
    nextSet$valuePrec2 <- currentSet$valuePrec1
    
    neighbours1value <- dataset[which(dataset$date==nextDate & dataset$point==neighbours[1]),][1,]
    val <- currentSet$neighbours1value
    if(nrow(neighbours1value)!=0)
    {
      val <- neighbours1value$value
    }
    
    nextSet$neighbours1value <- val
    nextSet$neighbours1valuePrec1 <- currentSet$neighbours1value
    nextSet$neighbours1valuePrec2 <- currentSet$neighbours1valuePrec1
    
    neighbours2value <- dataset[which(dataset$date==nextDate & dataset$point==neighbours[2]),][1,]
    val <- currentSet$neighbours2value
    if(nrow(neighbours2value)!=0)
    {
      val <- neighbours2value$value
    }
    
    nextSet$neighbours2value <- val
    nextSet$neighbours2valuePrec1 <- currentSet$neighbours2value
    nextSet$neighbours2valuePrec2 <- currentSet$neighbours2valuePrec1
    
    neighbours3value <- dataset[which(dataset$date==nextDate & dataset$point==neighbours[3]),][1,]
    val <- currentSet$neighbours3value
    if(nrow(neighbours3value)!=0)
    {
      val <- neighbours3value$value
    }
    
    nextSet$neighbours3value <- val
    nextSet$neighbours3valuePrec1 <- currentSet$neighbours3value
    nextSet$neighbours3valuePrec2 <- currentSet$neighbours3valuePrec1
    
    resultSet <- rbind(resultSet, nextSet)
  }
  
  return(resultSet)
}

addNeighboursValues <- function(newSet, date)
{
  for(pointName in unique(newSet$points))
  {
    #str(pointName)
    neighbours <- getneighbours(newSet, pointName)
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours1value <- newSet[which(newSet$points==neighbours[1] & newSet$date==date),]$value
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours1valuePrec1 <- newSet[which(newSet$points==neighbours[1] & newSet$date==date),]$valuePrec1
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours1valuePrec2 <- newSet[which(newSet$points==neighbours[1] & newSet$date==date),]$valuePrec2
    
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours2value <- newSet[which(newSet$points==neighbours[2] & newSet$date==date),]$value
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours2valuePrec1 <- newSet[which(newSet$points==neighbours[2] & newSet$date==date),]$valuePrec1
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours2valuePrec2 <- newSet[which(newSet$points==neighbours[2] & newSet$date==date),]$valuePrec2
    
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours3value <- newSet[which(newSet$points==neighbours[3] & newSet$date==date),]$value
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours3valuePrec1 <- newSet[which(newSet$points==neighbours[3] & newSet$date==date),]$valuePrec1
    newSet[which(newSet$points==pointName & newSet$date==date),]$neighbours3valuePrec2 <- newSet[which(newSet$points==neighbours[3] & newSet$date==date),]$valuePrec2
  }
  
  return(newSet)
}



main <- function(parameters, fullset)
{
  for(name in parameters)
  {
    currentSet <- fullset[which(fullset$parameter==name),]
    
    #MLset <- prepData(currentSet)
    #WorkingSet <- PrepForPrediction(currentSet)
  }
}

mainForMercury <- function(dataset = data.frame())
{
  #dataset <- PrepForPrediction(dataset)
  #write.csv(x = dataset, file = "./dataset_for_filling.csv", row.names = FALSE)
  
  dataset <- read.csv(file = "./filledDataset.csv")
  PreviousSet <- read.csv(file = "./next_set.csv")
  PreviousSet$date <- as.Date(PreviousSet$date, format = "%Y-%m-%d")
  PreviousSet$points <- as.character(PreviousSet$points)
  dataset$date <- as.Date(dataset$date)
  
  dataset <- rbind(dataset, PreviousSet)
  write.csv(x = dataset, file = "./filledDataset.csv", row.names = FALSE)
  
  newSet <- NextDataset(dataset)
  
  write.csv(x = newSet, file = "./next_set.csv", row.names = FALSE)
  
  return(newSet)
}
args = commandArgs(trailingOnly=TRUE)

setwd(dir = args[1])

library(stringr)
library(stringi)
library(lubridate)

#fullset <- read.csv("L:\\KRIGIS\\Krigis\\MachineLearning\\FullMesures.csv", fileEncoding = "UTF-8")
#fullset$date <- as.Date(fullset$date, format = "%m/%d/%Y")

#mercuryset <- fullset[which(fullset$parameter=="Mercure"),]

mainForMercury()