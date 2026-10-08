#!/bin/bash

USER=$(id -u)
LOG_DIR=/var/log/Shell-roboshop
LOG_File=$LOG_DIR/$0.log
DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if (($USER != 0)); then
   echo "please use root access to run the command"  |tee -a $LOG_File
   exit 1
fi

mkdir -p $LOG_DIR
VALIDATE()
{
  #echo "$1"
  if(($1==0)); then 
    echo "$2....... is SUCCESS" |tee -a $LOG_File
  else
    echo "$2 .......is FAILURE " |tee -a $LOG_File
    exit 1
  fi
}

dnf module disable nodejs -y &>>$LOG_File
dnf module enable nodejs:20 -y &>>$LOG_File
dnf install nodejs -y &>>$LOG_File
VALIDATE $? "Enabling and Installing Nodejs"

id roboshop &>>$LOG_File
if (($? != 0));then

  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  VALIDATE $? "Creating user"
else 
  echo -e "User already exists $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory "

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_File
VALIDATE $? "Installing roboshop user "

cd /app

rm -rf /app/* &>>$LOG_File
VALIDATE $? "Removing existing files"

unzip /tmp/user.zip &>>$LOG_File
VALIDATE $? "Unzipping user files"

npm install &>>$LOG_File
VALIDATE $? "Installing dependencies"

cp $DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "creting systemctl service"

systemctl daemon-reload &>>$LOG_File
systemctl enable user &>>$LOG_File
systemctl start user
VALIDATE $? "Enabling and Starting user"