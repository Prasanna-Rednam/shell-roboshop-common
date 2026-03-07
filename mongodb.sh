#!/bin/bash

source ./common.sh


check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying Mongo Repo" 

dnf install mongodb-org -y &>>$LOGS_FILE
validate $? "Installing MongoDB server"

systemctl enable mongod &>>$LOGS_FILE
validate $? "Enable MongoDB"

systemctl start mongod
validate $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections"

systemctl restart mongod
validate $? "Restarted MongoDB"

print_total_time
