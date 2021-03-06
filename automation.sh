#!/bin/bash
#test
s3_bucket="upgrad-madhurim"
myname="madhuri"

sudo apt update -y


#check if apache is installed or not 

if [ `dpkg --get-selections | grep apache | wc -l` == 4 ]
then 
	echo "Apache2 is installed"
else
	echo "Installing Apache2"
	sudo apt install apache2 -y
fi

#check if apache2 is running or not

if [ `service apache2 status | grep running | wc -l` == 1 ]
then 
	echo "Apache2 is in running state"
else
	echo "Starting the Apache2 server"
	sudo service apache2 start
fi

#Check if apache2 is enabled or not

if [ `systemctl status apache2 | grep "active (running)" | wc -l` == 1 ]
then
	echo "Apache2 is enabled"
else
	echo "Enabling the Apache server"
	sudo systemctl start apache2
	echo "Enabled Apache2"
fi


#creating a tar archive of apache2 logs

timestamp="$(date '+%d%m%Y-%H%M%S')"
file_name="/tmp/${myname}-httpd-logs-${timestamp}.tar"

tar -cf ${file_name} $( find /var/log/apache2/ -name "*.log")
echo "Archived the apache2 logs"

#Copy the archive to S3 bucket
aws s3 \
cp ${file_name} \
s3://${s3_bucket}/${file_name}
echo "Copied the archive to S3"



################ Task3 ############################

#Bookeeping
if [ -e /var/www/html/inventory.html ]
then
        echo "Inventory.html file exists"
else
        echo "Creating Inventory.html"
        touch /var/www/html/inventory.html
        echo "  Log Type                Date Created            Type            Size" >> /var/www/html/inventory.html
fi

echo "Updating the inventory.html"
echo "  httpd-log               ${timestamp}             tar            `du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}'`" >> /var/www/html/inventory.html


#Cron Job

if [ -e /etc/cron.d/automation ]
then
        echo "Cron Job is present"
else
        echo"Creating the cron job that runs every midnight"
        touch /etc/cron.d/automation
        echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi

