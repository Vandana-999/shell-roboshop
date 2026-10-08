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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying repo"

dnf install mongodb-org -y &>> $LOG_File
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>> $LOG_File
systemctl start mongod 
VALIDATE $? "Enabling and starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing traffic"

systemctl restart mongod
VALIDATE $? "Restarting mongodb"