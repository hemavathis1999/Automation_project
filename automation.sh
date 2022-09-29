name="hema"
s3_bucket="hss3"

apt update -y

if [[ apache2 != $(dpkg --get-selections apache 2 | awk '{print $1}' ) ]]; then
        apt install apache2 -y
fi

running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()' )
if [[ running != ${running} ]]; then
        systemctl start apache2

fi

enabled=$(systemctl is-enabled apache2 | grep "enabled" )
if [[ enabled != ${enabled} ]]; then
        systemctl enable apache2
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/$name-httpd-logs-${timestamp}.tar *.log

aws s3 \
cp /tmp/$name-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${hema}-httpd-logs-${timestamp}.tar

if [ -f "/var/www/html/inventory.html" ]
then
echo "File is found"
else

        echo "File creating ..........."
	cat >>/var/www/html/inventory.html << EOF
<table width="20%" cellspacing="0" cellpadding="5">
        <thead>
            <h4><th>Log Type </th></h4>
            <h4><th>Time Created </th></h4>
            <h4><th>Type </th></h4>
            <h4><th>Size </th><h4>
        </thead>
</table>
EOF
fi

size=$(du -h /tmp/$name-httpd-logs-${timestamp}.tar | awk '{print $1}')
cat >>/var/www/html/inventory.html << EOF
<table width="20%" cellspacing="0" cellpadding="5">
        <tbody>
       <tr>
       <td>httpd-logs</td>
       <td>${timestamp}</td>
       <td>tar</td>
       <td>$size</td>
       </tr>
       </tbody>
</table>
EOF



if [ -f "/etc/cron.d/automation" ]
then
echo "File is found"

else
  cat >>/etc/cron.d/automation << EOF
   0 12 * * *  /root/Automation_project/automation.sh
EOF
fi



