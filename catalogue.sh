#!/bin/bash
USER=$(id -u)
LOG_DIR=/var/log/Shell-roboshop
LOG_File=$LOG_DIR/$0.log
DIR=$PWD
MONGODB_HOST=mongodb.rivare.online


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

dnf module disable nodejs -y &>> $LOG_File
dnf module enable nodejs:20 -y &>> $LOG_File
dnf install nodejs -y &>> $LOG_File
VALIDATE $? "Installing Nodejs"

id roboshop &>> $LOG_File
if (($? != 0));then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating user"
else
   echo -e "create User ...$Y Skipping $N"
fi

mkdir -p /app 
VALIDATE $? "creating app directory "

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_File
VALIDATE $? "Installing catalogue"

cd /app 
VALIDATE $? "changing directory"

rm -rf /app/*
unzip /tmp/catalogue.zip &>> $LOG_File
VALIDATE $? "Unzip catalogue"

npm install  &>> $LOG_File
VALIDATE $? "Installing dependencies"

cp $DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "copying catalogue"

systemctl daemon-reload &>> $LOG_File
systemctl enable catalogue &>> $LOG_File
systemctl start catalogue
VALIDATE $? "Stating catalogue"

cp $DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>> $LOG_File
VALIDATE $? "Installing mongodb"


INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>> $LOG_File
if (( $INDEX <= 0 ));then
  mongosh --host mongodb.rivare.online </app/db/master-data.js &>> $LOG_File
else 
  echo -e "Repository already exists "
fi
systemctl restart catalogue
VALIDATE $? "Restarting catalogue"
