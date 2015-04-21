getData <- function(fileURL, filename) {
        if(!file.exists(filename)) {
                download.file(fileURL, filename, method="curl")
        }
}

getOriginalData <- function() {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        filename <- "UCI_HAR_Dataset.zip"
        getData(fileURL, filename)
}

getCourseraData <- function() {
        fileURL <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
        filename <- "Coursera_UCI_HAR_Dataset.zip"
        getData(fileURL, filename)
}

unzipData <- function(fileName) {
        unzip(fileName)
}

getColumnMetaData <- function() {
        fixFieldNames <- function(x) {
                gsub("[\\-,]","_", gsub("[\\(\\)]","", x, perl=TRUE), perl=TRUE)
        }

        features <- read.csv("UCI_HAR_Dataset/features.txt", sep=" ",
                     header=FALSE, col.names=c("Field_number", "Field_Name"),
                     stringsAsFactors = FALSE)
        colNames <- sapply(features[,2], fixFieldNames, simplify=TRUE,
                           USE.NAMES=FALSE)
        meanAndStd <- grepl("\\-mean\\(|\\-std\\(", features[,2])
        colClasses <- rep("NULL", nrow(features))
        colClasses[meanAndStd] <- "numeric"
        featuresToCapture <- features[meanAndStd,]
        cbind(features, colClasses=colClasses, colNames=colNames,
              stringsAsFactors=FALSE)
}

readSensorData <- function(filename) {
        columns <- getColumnMetaData()
        read.csv(filename, header=FALSE, sep="", colClasses=columns$colClasses,
                 col.names=columns$colNames)
}

readSubjectData <- function(filename) {
        read.csv(filename, header=FALSE, sep="", colClasses="numeric",
                 col.names=c("subject_id"))
}

readActivityLabels <- function(filename) {
        colNames <- c("activity_id", "activity_label")
        colTypes  <- c("numeric", "character")
        read.csv(filename, header=FALSE, sep="", colClasses=colTypes,
                 col.names=colNames,
                 stringsAsFactors=FALSE)
}

readActivityId <- function(filename, activity_lookup) {
        tmp <- read.csv(filename, header=FALSE, sep="", colClasses="numeric",
                        col.names=c("activity_id"))
        tmp$activity_id <- factor(tmp$activity_id,
                                  levels=activity_lookup$activity_id,
                                  labels=activity_lookup$activity_label)
}

buildDataSet <- function(setType) {
        # Construct directory path and file names for input data
        baseDir <- "UCI_HAR_Dataset"
        dataDir <- file.path(baseDir, setType)
        measureFilename <- paste("X_", setType, ".txt", sep="")
        subjectIdFilename <- paste("subject_", setType, ".txt", sep="")
        activityIdFilename <- paste("y_", setType, ".txt", sep="")
        activityLabelsFilename <- file.path(baseDir, "activity_labels.txt")

        subjectId <- readSubjectData(file.path(dataDir, subjectIdFilename))
        setTypeCol <- rep(setType,length(subjectId))
        activity_labels <- readActivityLabels(activityLabelsFilename)
        activityId <- readActivityId(file.path(dataDir, activityIdFilename),
                                     activity_labels)
        measures <- readSensorData(file.path(dataDir, measureFilename))
        cbind(subjectId, activityId, setType, measures)
}