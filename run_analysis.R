library(dplyr, warn.conflicts=FALSE)
library(reshape, warn.conflicts=FALSE)

# Helper function to download files if they do not already exist.
getRemoteData <- function(fileURL, filename) {
        if(!file.exists(filename)) {
                print(paste("Downloading file", fileURL))
                print(paste("To", filename))
                download.file(fileURL, filename, method="curl")
        }
}

# Function to retrieve the Original Data set for comparison to Coursera data
getOriginalData <- function() {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        filename <- "UCI_HAR_Dataset.zip"
        getRemoteData(fileURL, filename)
}

# Retrieve Coursera UCI HAR data set for class project.
getCourseraData <- function() {
        fileURL <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
        filename <- "Coursera_UCI_HAR_Dataset.zip"
        getRemoteData(fileURL, filename)
}

# Unzip the specified file into the UCI HAR Dataset directory
unzipUciHarData <- function(fileName, force=FALSE) {
        if (force) {
                unlink("UCI HAR Dataset", recursive=TRUE, force=TRUE)
        }
        if (!file.exists("UCI HAR Dataset")) {
                print(paste("unzipping", fileName))
                unzip(fileName)
        } else if (force) {
                error("UCI HAR Dataset directory could not be deleted!")
        }
        if (file.exists("__MACOSX")) {
                unlink("__MACOSX", recursive=TRUE, force=TRUE)
        }
}

# Convenience function to download and unzip the UCI Har Dataset in one step
stageUciHarData <- function() {
        getCourseraData()
        unzip("Coursera_UCI_HAR_Dataset.zip", junkpaths=TRUE, exdir=".")
        #unzipUciHarData("Coursera_UCI_HAR_Dataset.zip")
}


# Read the features.txt file to get descriptive names for the tidy data set
# Keep any variable name that contains mean() or std() per David Hood's (CTA)
# comments found here:
# https://class.coursera.org/getdata-013/forum/thread?thread_id=30
#
# 1) Read the features.txt to get column names found in the test and train data
# 2) Format the feature names to remove the () from mean() and std()
# 3) Create a colClasses vector with all features.
#    "NULL" for features not containing mean() or std() in their names.
#    "numeric" for features that do contain mean()/std() in their names.
# 4) Create a data.frame with the original features.txt data with the derived
#    colClasses and colNames values.
getColumnMetaData <- function() {
        fixFieldNames <- function(x) {
                gsub("[\\-,]","_", gsub("[\\(\\)]","", x, perl=TRUE), perl=TRUE)
        }

        features <- read.csv("features.txt", sep=" ",
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

# Read the sensor data for only the mean()/std() values.
readSensorData <- function(filename) {
        columns <- getColumnMetaData()
        read.csv(filename, header=FALSE, sep="", colClasses=columns$colClasses,
                 col.names=columns$colNames)
}

# Read the subject_id values into memory
readSubjectData <- function(filename) {
        read.csv(filename, header=FALSE, sep="", colClasses="numeric",
                 col.names=c("subject_id"))
}

# Read the activity id and activity labels referene table into memory
readActivityLabels <- function(filename) {
        colNames <- c("activity_id", "activity_label")
        colTypes  <- c("numeric", "character")
        read.csv(filename, header=FALSE, sep="", colClasses=colTypes,
                 col.names=colNames,
                 stringsAsFactors=FALSE)
}

# Read the activity values from the test/train data
# Apply the descriptive activity labels to the numeric values
readActivityId <- function(filename, activity_lookup) {
        tmp <- read.csv(filename, header=FALSE, sep="", colClasses="numeric",
                        col.names=c("activity_id"))
        tmp$activity_id <- factor(tmp$activity_id,
                                  levels=activity_lookup$activity_id,
                                  labels=activity_lookup$activity_label)
}


# Read the requested test or train UCI HAR Data set into memory
# 1) Read the corresponding X_test.txt or X_train.txt data
# 2) Read the corresponding subject_test.txt or subject_train.txt id values.
# 3) Read the corresponding y_test.txt or y_train.txt activity id values.
# 4) cbind them into a single data.frame with the test/train derived setType
buildUciHarDataSet <- function(setType) {
        # Construct directory path and file names for input data
        # baseDir <- "UCI HAR Dataset"
        # dataDir <- file.path(baseDir, setType)
        baseDir <- "."
        dataDir <- "."
        measureFilename <- paste("X_", setType, ".txt", sep="")
        subjectIdFilename <- paste("subject_", setType, ".txt", sep="")
        activityIdFilename <- paste("y_", setType, ".txt", sep="")
        activityLabelsFilename <- file.path(baseDir, "activity_labels.txt")

        subjectId <- readSubjectData(file.path(dataDir, subjectIdFilename))
        #setTypeCol <- rep(setType,length(subjectId))
        activity_labels <- readActivityLabels(activityLabelsFilename)
        activityId <- readActivityId(file.path(dataDir, activityIdFilename),
                                     activity_labels)
        measures <- readSensorData(file.path(dataDir, measureFilename))
        cbind(subjectId, activityId, setType, measures)
}

# Aggregate the data into mean values for each feature for each subject and
# activity. The setType variable is also used to ensure test and train data
# does not get mixed in the event there are duplicate subject_id values between
# the test and train data.
summarizeUciHarDataSet <- function(x) {
        x %>% group_by(subject_id, activityId, setType) %>%
                summarise_each(funs(mean)) %>% as.data.frame()
}


# Create a narrow data set with 5 columns
# 1) subject_id
# 2) activityId
# 3) setType
# 4) feature
# 5) mean value of feature for each subject and activity.
meltUciHarDataSet <- function(x) {
        idNames <- names(x)[1:3]
        melt.data.frame(x, id=idNames,
                        variable_name="feature")
}

# Create a data.frame of tidy data with the combinded test and train
# UCI HAR data using the functions described above.
# 1) Build UCI HAR Data set for the test group
# 2) Summarize the data to obtain mean values for each feature
# 3) Melt the data.frame into a narrow data set
# 4) Do steps 1-3 for the train data
# 5) Append the two data.frames together using rbind.
buildUciHarTidyData <- function() {
        buildUciHarDataSet("test") %>%
                summarizeUciHarDataSet() %>%
                meltUciHarDataSet() %>% as.data.frame() -> testData
        buildUciHarDataSet("train") %>%
                summarizeUciHarDataSet() %>%
                meltUciHarDataSet() %>% as.data.frame() -> trainData
        rbind(testData, trainData)
}

executeUciHarTidyDataProject <- function(download=FALSE) {
        if (download) {
                print("Checking data dependency")
                stageUciHarData()
        }
        buildUciHarTidyData()
}

write.table(executeUciHarTidyDataProject(), file="tidydata.txt", row.names=FALSE)