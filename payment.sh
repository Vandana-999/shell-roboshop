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


dnf install python3 gcc python3-devel -y &>>$LOG_File
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

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_File
VALIDATE $? "Installing roboshop payment "

cd /app

rm -rf /app/* &>>$LOG_File
VALIDATE $? "Removing existing files"

unzip /tmp/payment.zip &>>$LOG_File
VALIDATE $? "Unzipping payment files"

pip3 install -r requirements.txt &>>$LOG_File
VALIDATE $? "Installing dependencies"

cp $DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "creting systemctl service"

systemctl daemon-reload &>>$LOG_File
systemctl enable payment &>>$LOG_File
systemctl start payment
VALIDATE $? "Enabling and Starting payment"