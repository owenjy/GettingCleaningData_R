####  1.1
####  set up working directory  and load packages
      #setwd("C:/Users/O2/R")
      getwd()
      ifelse(!file.exists("data"),dir.create("data"),"dir exists")
      #if(!file.exists("data")) {dir.create("data")} else {"No need to re-create"}
      
      install.packages("plyr")
      library(plyr)
      search()
######

####  1.2
####  download to working directory      
      file<-"http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      download.file(file,"./data/wear2.zip",mode='wb')
      unzip<-unzip("./data/wear2.zip")
######
   
####  1.3      
####  manipulate file.lists of freshedly unzipped files called unzip
      unzip2<-data.frame(unzip)
        ##  create folder variabe which indicates where files resides
      unzip2$folder[c(grep("(.*?)/test|train/(.*)txt$",unzip,invert=T))]<-'root'
      unzip2$folder[c(grep("(.*?)/test/(.*)txt$",unzip))]<-'test'
      unzip2$folder[c(grep("(.*?)/train/(.*)txt$",unzip))]<-'train'
        #unzip2$filename<-paste(unzip2$folder,gsub(".*\\/(.*)\\..*", "\\1", unzip),sep="_")
      unzip2$filename<-gsub(".*\\/(.*)\\..*", "\\1", unzip)
        ##unzip2_clean ignores filename that will not be read such as README.TXT!!
      unzip2_clean<-unzip2[c(grep("README|features_info",unzip2$filename,invert=T)),]
######

####  2.0 
####  Actual reading of txt files
      count=0
      for (i in 1:(length(unzip2_clean$filename)))
        {
          assign(as.character(unzip2_clean$filename[i]),cbind(data.frame(lapply(as.character(unzip2_clean$unzip[i]), read.table,header=F)),dataset_source=as.character(unzip2_clean$folder[i])))
          count=count+1
          cat(paste(paste(count,"-th",sep=""), "\tfile loaded:", as.character(unzip2_clean$filename[i]),"\n")) 
        }
######

####  3.0      
####  Applying column names to X_train and X_test based on 561 features in "features.txt" and
  ##  newly created vairable "dataset_source" which indicate whether data coming from testing/train partition
      colnames(X_train)           <-c(gsub("_$","",gsub(",|-|\\(|\\)","_",gsub("\\(\\)","_of",features$V2))),"dataset_source")
      colnames(X_test)            <-c(gsub("_$","",gsub(",|-|\\(|\\)","_",gsub("\\(\\)","_of",features$V2))),"dataset_source")
        ##"()" are removed. "," and "-" are replaced with underscore "_"
      colnames(subject_test)[1]   <-"subject_id"
      colnames(subject_train)[1]  <-"subject_id"
      colnames(y_test)[1]         <-"activity_id"
      colnames(y_train)[1]        <-"activity_id"
      colnames(activity_labels)[1]<-"activity_id"
      colnames(activity_labels)[2]<-"activity"
      activity_labels[3]<-NULL
        ##clean up unused column name
######

####  4.0
####  Merge of files
      subject_train$key<-rownames(subject_train)
      subject_test$key <-rownames(subject_test)
      X_train$key <-rownames(X_train)
      y_train$key <-rownames(y_train)
      X_test$key <-rownames(X_test)
      y_test$key <-rownames(y_test)
      names(subject_train)
      names(X_train)
        ##create key for joining

      merge_train<-join(join_all(list(subject_train,X_train,y_train),by='key',type='inner')
                         ,activity_labels
                         ,by='activity_id'
                         ,type='inner')
      
      merge_test<-join(join_all(list(subject_test,X_test,y_test),by='key',type='inner')
                        ,activity_labels
                        ,by='activity_id'
                        ,type='inner')
######
      
####  4.1
####  Question 1: Merges the training and the test sets to create one data set.
  ##  STack train and test partitiont to create 1 data.frame
      merge_all<-rbind(merge_train,merge_test)
      merge_all$dataset_source_final<-merge_all$dataset_source
      merge_all$dataset_source<-NULL;merge_all$dataset_source<-NULL;merge_all$dataset_source<-NULL;
        ##remove duplicates dataset_source
      tapply(merge_all$key,merge_all$dataset_source_final,function(x) length(x))
        ##check number of obs per data sourse partition
######
      
####  4.2
####  Question 2: Extracts only the measurements on the mean and standard deviation for each measurement.
  ##  since mean() was replaced by mean_of; triggers are mean_of and std_of
      selectedCol<-c("subject_id"
        ,"key"
        ,"dataset_source_final"
        ,"activity_id"
        ,"activity"
        ,colnames(merge_all)[grep("mean_of|std_of",tolower(colnames(merge_all)))])
      Mean_Std_Only<-merge_all[,selectedCol]
      head(Mean_Std_Only)
######
      
####  4.3
####  Question 3: Uses descriptive activity names to name the activities in the data set
      head(merge_all[,c("activity_id","activity")],n=20)
######
      
####  4.4
####  Question 4: Appropriately labels the data set with descriptive activity names.    
######      
      
####  5
####  Creates a second, independent tidy data set with the average of each variable for each activity and each subject.      
      summary_per_subj<-data.frame(
        t(sapply(split(Mean_Std_Only[,c(colnames(merge_all)[grep("mean_of",tolower(colnames(merge_all)))])]
                      ,list(Mean_Std_Only$subject_id,Mean_Std_Only$activity)
                      )
            ,colMeans,na.rm=T)))
  
      subject_id<-gsub("(^[0-9][0-9]?)\\.(.+)","\\1",rownames(summary_per_subj))
      acitivity <-gsub("(^[0-9][0-9]?)\\.(.+)","\\2",rownames(summary_per_subj))
      summary_per_subj<-cbind(subject_id,acitivity,summary_per_subj)
      
      rownames(summary_per_subj)<-1:length(rownames(summary_per_subj))
      head(summary_per_subj[order(c(subject_id,acitivity)),1:15],100)

      cat("# of ALL variables: ",           "\t\t", length(colnames(summary_per_subj)), 
          "\n# of ID variables: ",          "\t\t", length(grep("mean_of",colnames(summary_per_subj),invert=T)),
          "\n# of variables with XYZ: ",    "\t\t", length(grep("mean_of_[A-Z]",(colnames(summary_per_subj)))),
          "\n# of variables withOUT XYZ: ", "\t\t", length(grep("mean_of$",(colnames(summary_per_subj))))
          )
      
      ##export final tidy data in csv format to working directory
      write.table(summary_per_subj
                  ,file="./data/final_tidy_data_JY.csv"
                  ,sep = ",", qmethod = "double",
                  row.names=F)
      write.table(summary_per_subj
                  ,file="./data/final_tidy_data_JY.txt"
                  ,sep = ",", qmethod = "double",
                  row.names=F)