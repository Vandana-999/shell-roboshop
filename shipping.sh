#!/bin/bash

USER=$(id -u)
LOG_DIR=/var/log/Shell-roboshop
LOG_File=$LOG_DIR/$0.log
DIR=$PWD
MYSQL_HOST=mysql.rivare.online

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


dnf install maven -y &>>$LOG_File
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

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_File
VALIDATE $? "Installing roboshop shipping "

cd /app
rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_File
VALIDATE $? "Uzip shipping code"

mvn clean package &>>$LOG_File
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "renaming jar file "

cp $DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "creting systemctl service"

systemctl daemon-reload &>>$LOG_File


dnf install mysql -y &>>$LOG_File
VALIDATE $? "Installing mysql"


mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_File
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_File
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_File
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi


systemctl enable shipping &>>$LOG_File
systemctl start shipping
VALIDATE $? "Enabling and Starting shipping"
