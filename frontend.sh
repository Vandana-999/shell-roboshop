#!/bin/bash

USER=$(id -u)
LOG_DIR=/var/log/Shell-roboshop
LOG_File=$LOG_DIR/$0.log

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

dnf module disable nginx -y &>>$LOG_File
dnf module enable nginx:1.24 -y &>>$LOG_File
dnf install nginx -y &>>$LOG_File
VALIDATE $? "Installing nginx"

systemctl enable nginx  &>>$LOG_File
systemctl start nginx 
VALIDATE $? " Enable and start nginx "

rm -rf /usr/share/nginx/html/* &>>$LOG_File
VALIDATE $? "Removing existing html files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_File
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_File
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf

cp $DIR/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "copying conf file"

systemctl restart nginx  &>>$LOG_File
VALIDATE $? "Restarting nginx"