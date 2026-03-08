#!/bin/bash

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33m"
N="\e[0m"
RID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"
MONGODB_HOST="mongodb.praws.online"
SCRIPT_DIR=$PWD

START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER

DATE=$(date "+%Y-%m-%d %H:%M:%S") 
echo " $DATE | script started executing at: $DATE" | tee -a $LOGS_FILE

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
   #creating system user
   id roboshop &>>$LOGS_FILE
   if [ $? -ne 0 ]; then
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
       VALIDATE $? "Creating system user"
   else
        echo -e "Roboshop user already exist ... $Y SKIPPING $N"
   fi
   #App setup 
   mkdir -p /app 
   VALIDATE $? "Creating app directory"

   curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOGS_FILE
   VALIDATE $? "Downloading $app_name code"

   cd /app
   VALIDATE $? "Moving to app directory"

   rm -rf /app/*
   VALIDATE $? "Removing existing code"

   unzip /tmp/$app_name.zip &>>$LOGS_FILE
   VALIDATE $? "Uzip $app_name code"

}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Created systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name  &>>$LOGS_FILE
    systemctl start $app_name
    VALIDATE $? "Starting and enabling $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name"
}

print_total_time(){
    END_TIME=$(date +%S)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e " $DATE | Script execute in: $GREEN $TOTALTIME Seconds $N " | tee -a $LOGS_FILE
}

