#!/bin/bash

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33m"
N="\e[0m"
RID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"

START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER


echo " $(date "+%Y-%m-%d %H:%M:%S") | script started executing at: $(date)" | tee -a $LOGS_FILE

USER_ID=$(id -u)
check_root(){

   if [ $USER_ID -ne 0 ]; then
   echo -e "$RED please run this script with root user access $N"
   exit 1
   fi
}



VALIDATE(){
    if [ $1 -ne 0 ]; then 
      echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $RED $2... failure " | tee -a $LOGS_FILE
    
   else
      echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $GREEN $2 ... sucess " | tee -a $LOGS_FILE
    fi       
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling NodeJS Default version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NodeJS 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Install NodeJS"

    npm install  &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){

   mkdir -p /app 
   VALIDATE $? "Creating app directory"

   curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
   VALIDATE $? "Downloading catalogue code"

   cd /app
   VALIDATE $? "Moving to app directory"

   rm -rf /app/*
   VALIDATE $? "Removing existing code"

   unzip /tmp/catalogue.zip &>>$LOGS_FILE
   VALIDATE $? "Uzip catalogue code"


}


print_total_time(){
    END_TIME=$(date +%S)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e " $(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $GREEN $TOTALTIME Seconds $N " | tee -a $LOGS_FILE
}

