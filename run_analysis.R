library(dplyr)


filename = "dataset.zip"
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}


X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")


activity_labels <- read.table("./activity_labels.txt")

features <- read.table("./features.txt", col.names = c("n", "feature"))
features_cols <- features$feature[grep("mean\\(\\)|std\\(\\)", features$feature)]
names <- sapply(features$feature, as.character)

names(X_train) <- names
names(X_test) <- names

names(y_train) <- c("activity")
names(y_test) <- c("activity")

names(subject_train) <- c("subject")
names(subject_test) <- c("subject")


df <- rbind(X_train, X_test)
df_activity <- rbind(y_train, y_test)
df_subject <- rbind(subject_train, subject_test)

df_merged <- df[, features_cols]
df_extracted <- cbind(df_subject, df_merged, df_activity)

df_extracted <- mutate(df_extracted, activity = activity_labels[activity, 2])


names(df_extracted) <- gsub("^t", "time", names(df_extracted))
names(df_extracted) <- gsub("^f", "frequency", names(df_extracted))
names(df_extracted) <- gsub("Acc", "Accelerometer", names(df_extracted))
names(df_extracted) <- gsub("Gyro", "Gyroscope", names(df_extracted))
names(df_extracted) <- gsub("Mag", "Magnitude", names(df_extracted))
names(df_extracted) <- gsub("BodyBody", "Body", names(df_extracted))


tidy_df <- group_by(df_extracted, subject, activity)
tidy_df <- summarise_all(tidy_df, funs(mean))

write.table(tidy_df, "FinalData.txt", row.name=FALSE)