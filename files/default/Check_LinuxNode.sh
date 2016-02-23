#!/bin/bash
##############################################################
#
#  Created On:  09/03/2015
#  Author:  Jamin Shanti
#  Purpose: Check Linux Nodes
#
###############################################################
# cronjob usage: 0 */4 * * * /home/ec2-user/Check_LinuxNode.sh >> /home/ec2-user/Check_LinuxNode_Log.log 2>&1

timenow=$(date +"%FT%T")
echo "The time is $timenow"
echo "Get Instance information..."
REGION=$(curl -sS http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
instanceId=$(curl -sS http://169.254.169.254/latest/dynamic/instance-identity/document|grep instanceId|awk -F\" '{print $4}')
instanceName=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceId" "Name=key,Values=Name" --region $REGION --output=text | cut -f5)
echo "instanceID:      "$instanceId
echo "Region:      "$REGION
echo "instanceName:      "$instanceName

echo "Collecting Memory Utilization"
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%)\n", $3,$2,$3*100/$2 }'
MemoryUtilization=$(free -m | awk 'NR==2{printf "%.8f",$3*100/$2 }')

echo "Collecting Yum Update Count..."
updateCriticalCount=$(yum check-update --security | grep -v Security: | egrep '(.i386|.x86_64|.noarch|.src)' | wc -l)
echo "SystemUpdateCritical:      "$updateCriticalCount
updateCount=$(yum check-update | grep -v Security: | egrep '(.i386|.x86_64|.noarch|.src)' | wc -l)
#remove the Critical from the count
updateCount=$((updateCount-updateCriticalCount))
echo "SystemUpdateImportant:     "$updateCount

echo "Checking Disk Usage..."
disks=$(df -k | grep -vE "^Filesystem|shm|boot|tmpfs")
while read  disk; do
    fsystem=$(echo "$disk" | awk '{print $1}')
    echo "Attached Volume:    "$fsystem
    disk_total=$(echo $disk | awk '{print $2}')
    echo "Disk total:    "$disk_total
    disk_used=$(echo $disk | awk '{print $3}')
    echo "Disk Used:    "$disk_used
    disk_avail=$(echo $disk | awk '{print $4}')
    echo "Disk Available:    "$disk_avail
    disk_util=$(echo $disk | awk '{print $5}' | sed 's/%//'g)
    echo "Disk Utilization:    "$disk_util
    mount=$(echo $disk | awk '{print $6}')
    echo "Disk Mount:    "$mount  
    echo "Put VolumeUtilization on AWS..." 
    aws cloudwatch put-metric-data --metric-name VolumeUtilization --namespace "System/Linux" --value $disk_util --unit "Count" --timestamp $timenow --region $REGION --dimensions="Filesystem=$fsystem,InstanceId=$instanceId,MountPath=$mount" 
done <<< "$disks"

echo "Checking Mcafee version information..."
/opt/NAI/LinuxShield/bin/nails -v || echo "No Mcafee Found..."
AVDatVersion=$(/opt/NAI/LinuxShield/bin/nails -v | grep definition | awk {'print $4'})
if [ -z "$AVDatVersion" ]; then
    AVDatVersion=0
fi
echo "AVDatVersion is $AVDatVersion"

echo "Put Other Metrics to AWS..."

aws cloudwatch put-metric-data --metric-name MemoryUtilization --namespace "System/Linux" --value $MemoryUtilization --unit "Percent" --timestamp $timenow --region $REGION --dimensions="InstanceId=$instanceId,InstanceName=$instanceName"
aws cloudwatch put-metric-data --metric-name SystemUpdatesCritical --namespace "System/Linux" --value $updateCriticalCount --unit "Count" --timestamp $timenow --region $REGION --dimensions="InstanceId=$instanceId,InstanceName=$instanceName"
aws cloudwatch put-metric-data --metric-name SystemUpdatesImportant --namespace "System/Linux" --value $updateCount --unit "Count" --timestamp $timenow --region $REGION --dimensions="InstanceId=$instanceId,InstanceName=$instanceName"
aws cloudwatch put-metric-data --metric-name AVDatVersion --namespace "System/Linux" --value $AVDatVersion --unit "Count" --timestamp $timenow --region $REGION --dimensions="InstanceId=$instanceId,InstanceName=$instanceName"
