#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo " "
echo " "

echo "Downloading latest Azure tuneable file..."
echo "*****************************************"
wget -N -q -P /etc/sysctl.d http://wolverine.itscloudy.af/config/98-rhel7-azure-sysctl.conf

echo " "
echo " "

echo "Setting SELinux Context..."
echo "**************************"
chcon --reference=/etc/sysctl.conf /etc/sysctl.d/98-rhel7-azure-sysctl.conf

echo " "
echo " "

echo "Calling sysctl to re-read configuration..."
echo "******************************************"
/usr/sbin/sysctl -q --system

echo " "
echo " "

echo "Installing epel-release, deltarpm and telnet RPMs..."
echo "****************************************************"
yum -q -y install epel-release deltarpm telnet

echo " "
echo " "

echo "Verifying accelerated networking is available..."
echo "************************************************"
if [ -n "`lspci |grep -i mellanox`" ]
then
   echo -e "${GREEN}Verified.${NC}"
else
   echo -e "Accelerated networking is ${RED}*NOT*${NC} available on this host!"
fi

echo " "
echo " "

echo "Verifying accelerated networking is functioning..."
echo "**************************************************"
if [ "`ethtool -S eth0 | grep vf_rx_bytes |awk '{print $2}'`" -gt "0" ]
then
   echo -e "Accelerated networking is ${GREEN}enabled${NC} and appears to be functioning."
else
   echo -e "Accelerated networking does ${RED}*NOT*${NC} appear to be functioning."
fi
