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

dnf module disable redis -y &>>$LOG_File
dnf module enable redis:7 -y&>>$LOG_File
dnf install redis -y &>>$LOG_File
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOG_File
systemctl start redis 
VALIDATE $? "Enable and start redis"