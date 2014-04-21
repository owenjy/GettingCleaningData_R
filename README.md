## Overview

This README.md file explains how I, Jin YUN, used **R programming** to load and cleanse raw data stored in zipped txt files and finally create tidy data.  

Details about this assignment  
https://class.coursera.org/getdata-002/human_grading/view/courses/972080/assessments/3/submissions

## Overall R Program Flow

My program is divided into 5 blocks from 1.0...3.0,...to 5.0.


## Detailed Explaination Block by Block
###1. Preparation  
        1.1 Install requited R package and create directory "data" under working directory  
        1.2 Download zip file to "./data" folder and unzip it using unzip() function  
        1.3 Create a data.frame called unzip2 that stores .*txt files's path 

  Also create flag variable "folder" which indicates whether a particular .txt file resides in 'test','train' or 'root' folder. (useful  when stacking up training and test datasets later)
  
  Lastly, create unzip2_clean which removes .txt files that will NOT read; namely: readme.txt and feature_info.txt
  
###2. Read in all eligible .txt files recursively within downloaded/supplied zip file  
        data.frame named according to naming of .txt file. 
        For example, ..\UCI HAR Dataset\test\X_test.txt  is read and stored in data.frame named "X_test".
In total 26 .txt files are read and stored as data.frame. They are:

        "1-th file loaded: activity_labels"
    	"2-th file loaded: features"
		"3-th file loaded: body_acc_x_test"
		"4-th file loaded: body_acc_y_test"
		"5-th file loaded: body_acc_z_test"
		"6-th file loaded: body_gyro_x_test"
		"7-th file loaded: body_gyro_y_test"
		"8-th file loaded: body_gyro_z_test"
		"9-th file loaded: total_acc_x_test"
		"10-th file loaded: total_acc_y_test"
		"11-th file loaded: total_acc_z_test"
		"12-th file loaded: subject_test"
		"13-th file loaded: X_test"
		"14-th file loaded: y_test"
		"15-th file loaded: body_acc_x_train"
		"16-th file loaded: body_acc_y_train"
		"17-th file loaded: body_acc_z_train"
		"18-th file loaded: body_gyro_x_train"
		"19-th file loaded: body_gyro_y_train"
		"20-th file loaded: body_gyro_z_train"
		"21-th file loaded: total_acc_x_train"
		"22-th file loaded: total_acc_y_train"
		"23-th file loaded: total_acc_z_train"
		"24-th file loaded: subject_train"
		"25-th file loaded: X_train"
		"26-th file loaded: y_train"
Each data.frame will have one variable called "dataset_source" which indicates whether data coming from testing/train partition

###3. Apply labels to variables according to supplied README file
        X_train/X_test columns are assigned automatically using "features.txt" supplied. 
	    column names "subject_id","activity_id","activity" are applied by "hard coding"  
Format columns names to enhence readability:

		Matching () to _of. mean() changed to mean_of
		All other delimiters: -,(,) changed to _
		if variable ends with _, its last character_ is removed
		e.g. fBodyAccJerk-mean()-X    ->      fBodyAccJerk_mean_of_X

###4. Merge Testing and Training datasets to create one dataset

    4.1. Used "plyr" package to join data.frame based on row_number variable call "key"
		4.1.1. merge subject_train, X_train,    y_train to create training dataset
		4.1.2. merge subject_test,  X_test,     y_test to create testing dataset
		4.1.3. bring in description of activity_id by merging with activity_labels by activity_id
		4.1.4. all join done by "inner join"
		4.1.5. merge_all contains both training and testing data by stack up merge_train and merge_test  
        
	4.2. Extracts only the measurements on the mean and standard deviation for each measurement
		4.2.1. completed by grep() 
		4.2.2. [ouptput:] head(Mean_Std_Only)
        
	4.3.-4.4 Uses descriptive activity names to name the activities in the data set and Appropriately labels the data set with descriptive activity names
		[4.3 and 4.3 ouptput:] head(merge_all[,c("activity_id","activity")],n=20)
###5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

	5.1. Create summary data per subject per activity by:
		First select only variables that contains "mean()"; 
		Then split data.frame by (subject_id and activity);
		Then calculate mean using sapply();   
		and finally transpose resulting data.frame
	
    5.2. Further clean up data.frame "summary_per_subj" by create two variables "subject_id","acitivity"
	
    5.3. Final oupput is: "summary_per_subj" which has 33 variables storing mean of measurement of each acitivity of each subject.  
		# of ALL variables:  		35 
		# of ID variables:  		 2 
		# of variables with XYZ:     24 
		# of variables withOUT XYZ:  9
	