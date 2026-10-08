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

cp $DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Creating repo"

dnf install rabbitmq-server -y &>>$LOG_File
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_File
systemctl start rabbitmq-server
VALIDATE $? "Enable and start Rabbitmq"

rabbitmqctl add_user roboshop roboshop123  &>>$LOG_File
VALIDATE $? "Add User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_File
VALIDATE $? "set permessions"