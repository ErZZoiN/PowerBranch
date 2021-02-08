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