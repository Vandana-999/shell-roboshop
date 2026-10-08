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

dnf install mysql-server -y &>>$LOG_File
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOG_File
systemctl start mysqld  &>>$LOG_File
VALIDATE $? "Enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_File
VALIDATE $? "Setting password"