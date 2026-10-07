#!/bin/bash
SG_ID=sg-07005b0cd17c8de55
AMI_ID=ami-0220d79f3f480ecf5
Domain_Name=rivare.online
HZone_Id=Z01865283SULMZB5GI5LA


for instance in $@
do
instance_id=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
  if [ $instance == "frontend" ]; then
    IP=$(
    aws ec2 describe-instances \
  --instance-ids $instance_id \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
    )
  
  else 
    IP=$(
    aws ec2 describe-instances \
  --instance-ids $instance_id \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text
    )
  fi
  echo "IP Adress : $IP"

  aws route53 change-resource-record-sets \
  --hosted-zone-id $HZone_Id \
  --change-batch '
        {
        "Comment": "Updating A record",
        "Changes": [
          {
            "Action": "UPSERT",
            "ResourceRecordSet": {
              "Name": "'$Domain_Name'",
              "Type": "A",
              "TTL": 1,
              "ResourceRecords": [
                {
                  "Value": "'$IP'"
                }
              ]
            }
          }
        ]
      }
  '
done
