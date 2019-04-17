#!/bin/bash

# Written by Stuart Kirk
# stuart.kirk@microsoft.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

IFACE=eth0

yum -y install iptables-services rsyslog 

systemctl stop firewalld 
systemctl disable firewalld
systemctl mask firewalld
systemctl enable iptables
systemctl start iptables
systemctl reload iptables

touch /var/log/iptables.log

echo ":msg, contains, \"DEPENDENCY\" -/var/log/iptables.log" > /etc/rsyslog.d/iptables.conf
echo "& stop" >> /etc/rsyslog.d/iptables.conf
systemctl restart rsyslog

iptables -N LOG_UNLESS
iptables -I INPUT 1  -i $IFACE -p tcp -m state --state NEW -j LOG_UNLESS
iptables -I OUTPUT -p tcp -m state --state NEW -j LOG_UNLESS
iptables -I LOG_UNLESS 1 -d 168.63.129.16 -j RETURN
iptables -I LOG_UNLESS 1 -d 169.254.169.254 -j RETURN
iptables -A LOG_UNLESS -i $IFACE -p tcp -m state --state NEW -j LOG --log-prefix "DEPENDENCY INPUT: "
iptables -A LOG_UNLESS -p tcp -m state --state NEW -j LOG --log-prefix "DEPENDENCY OUTPUT: "

touch /var/spool/cron/root
echo "* * * * * /usr/bin/netstat -Wnetpv | /usr/bin/egrep -v '(Internet|Proto)' >> /var/log/netstat.log 2>&1" >> /var/spool/cron/root
echo "* * * * * /usr/bin/echo \"Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      PID/Program name\" > /var/log/netstat-unique.log 2>&1" >> /var/spool/cron/root
echo "* * * * * /usr/bin/sleep 2;/usr/bin/sort -u /var/log/netstat.log >> /var/log/netstat-unique.log 2>&1" >> /var/spool/cron/root

