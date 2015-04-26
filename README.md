# getcleandata
Course project for Coursera::Getting and Cleaning Data
---
The **run_analysis.R** script has 15 functions that facilitate the gathering and
cleaning the UCI HAR data set.

The Coursera data and code book can be found here:  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The resutling tidy data set is a long narrow data.frame with 11,880 observation
representing a single measurement (feature) for a single activity for a unique 
subject.
```
'data.frame':        11880 obs. of  5 variables:
 $ subject_id: num  2 2 2 2 2 2 4 4 4 4 ...
 $ activityId: Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 2 3 4 5 6 1 2 3 4 ...
 $ setType   : Factor w/ 2 levels "test","train": 1 1 1 1 1 1 1 1 1 1 ...
 $ feature   : Factor w/ 66 levels "tBodyAcc_mean_X",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ value     : num  0.276 0.247 0.278 0.277 0.278 ...
```

```
features <- 66  ## There are a total of 66 features names containing mean() or std()
activities <- 6 ## There are six activities
subjects <- 30  ## There were 30 subjects  

features * activities * subjects
```

```
[1] ## 11880
```

# Functions
## executeUciHarTidyDataProject()
**parameters**: None  

**Description:**  
The **executeUciHarTidyDataProject** is the driver function that returns a tidy
dataset by getting and cleaning the data from the URL provided above. It can
be called as follows.
```
uciHarTidyData <- executeUciHarTidyDataProject()
```

The resulting data.frame will have 11,880 observations with 5 variables each.

variable|type
-|-
 subject_id| numeric
 activityId| Factor w/ 6 levels 
 setType   | Factor w/ 2 levels 
 feature   | Factor w/ 66 levels 
 value     | numeric

#### Example observations
no.|subject_id|activityId|setType|feature|value
-|-|-|-|-|-
1|2|WALKING|test|tBodyAcc_mean_X|0.27642659
2|2|WALKING|test|tBodyAcc_mean_Y|-0.01859492
3|2|WALKING|test|tBodyAcc_mean_Z|-0.10550036

**Note:** See code_book.html for full descriptions of each column

## getRemoteData(fileURL, filename)
**parameters:**  
fileURL = URL for specified file to download  
filename = local file to which the fileURL is written.  

**Description:**
Downloads the file specified by fileURL and writes it to the file specified by
filename.  **Note:** The file will not be downloaded if the local file already
exists.

## stageData()
**parameters:** None  

**Description:**  
The stageData() function takes no parameter and will download the zip file from
the above listed URL and uzip the contents into a folder named "UCI HAR Dataset"
in the current working directory.

## getOriginalData()
**parameters:** None  

**Description:**  
Function to retrieve the Original Data set for comparison to Coursera data.
Was not used in the creation of the tidy data set.  Merely a due-dilligence step.


## getCourseraData()
**parameters:** None  

**Description:**  
The getCourseraData() function will download the zip file from the following URL
provided the zip file does not already exist in the current working directory.  
URL: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
ZipFile: Coursera_UCI_HAR_Dataset.zip

## unzipUciHarData(fileName, force=FALSE)
**parameters:**  
fileName = file to unzip  
force = TRUE or FALSE. TRUE will unzip the archive over existing unzipped folder.

## getColumnMetadata()
**parameters:** None  

**Description:**  
Read the features.txt file to get descriptive names for the tidy data set.  
Keep any variable name that contains mean() or std() per David Hood's (CTA)
comments found here:  
https://class.coursera.org/getdata-013/forum/thread?thread_id=30  

1. Read the features.txt to get column names found in the test and train data
2. Format the feature names to remove the () from mean() and std() and change
'-' to '_'
3.  Create a colClasses vector with all features.
     + "NULL" for features not containing mean() or std() in their names.
     + "numeric" for features that do contain mean()/std() in their names.
4. Create a data.frame with the original features.txt data with the derived
colClasses and colNames values.
**Example**  

  Field_number|Field_Name|colClasses|colNames
-|-|-|-
1|tBodyAcc-mean()-X|numeric|tBodyAcc_mean_X
2|tBodyAcc-mean()-Y|numeric|tBodyAcc_mean_Y
3|tBodyAcc-mean()-Z|numeric|tBodyAcc_mean_Z
4|tBodyAcc-std()-X|numeric|tBodyAcc_std_X
5|tBodyAcc-std()-Y|numeric|tBodyAcc_std_Y
6|tBodyAcc-std()-Z|numeric|tBodyAcc_std_Z


## readSensorData(filename)
**parameters:**  
filename = file containing sensor data.  

**Description:**  
Read the sensor data importing only the mean()/std() columns as defined by
**getColumnMetaData**.


## readSubjectData(filename)
**parameters:**  
filename = file containing subject_id values corresponding to the sensor data.  

**Description:**  
Read the subject_id values corresponding to the sensor data.


## readActivityLabels(filename)
**parameters:**  
filename = File containing the activity id and label values.  

**Description:**  
Read the activity id and activity labels referene table into a data.frame.

## readActivityId(filename, activity_lookup)
**parameters:**  
filename = File containing the activity id values cooresonding with the sensor
data.  
activity_lookup = A data.frame containing the activity lookup data from
**readActivityLabels**  

**Description:**  
Reads the activity id values from the file specified by filename and formats
it as a factor with descriptive activity labels.

## buildUciHarDataSet(setType)
**parameters:**  
setType = Values "test" or "train" identify which subdirectory and cooresponding
data to read.  

**Description:**  
Read the requested test or train UCI HAR Data set into a data.frame.

1. Read the corresponding X_test.txt or X_train.txt data
2. Read the corresponding subject_test.txt or subject_train.txt id values.
3. Read the corresponding y_test.txt or y_train.txt activity id values.
4. cbind them into a single data.frame with the test/train derived setType

## summarizeUciHarDataSet(x)
**parameters:**
x = data.frame to aggregate down to mean values for each feature by subject_id
and activityId  

**Description:**  
Aggregate the data into mean values for each feature for each subject and
activity. The setType variable is also used to ensure test and train data
does not get mixed in the event there are duplicate subject_id values between
the test and train data.


## meltUciHarDataSet(x)
**parameters:**
x = data.frame to melt into a long narrow data.frame  

**Description:**  
Create a narrow data set with 5 columns

1) subject_id
2) activityId
3) setType
4) feature
5) mean value of feature by subject_id and activityId.

## buildUciHarTidyData()

**Description:**  
Create a data.frame of tidy data with the combinded test and train
UCI HAR data using the functions described above.

1) Build UCI HAR Data set for the test group
2) Summarize the data to obtain mean values for each feature
3) Melt the data.frame into a narrow data set
4) Do steps 1-3 for the train data
5) Append the two data.frames together using rbind.
