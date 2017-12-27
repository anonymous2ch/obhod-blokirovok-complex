#!/bin/bash
set -m

#FuckRoskomnadzor OpenVPN routing

#USAGE:

#Save this file into /etc/openvpn/up.sh
#Make sure you've chmod +x /etc/openvpn/up.sh
#Add the following lines to the top of your OpenVPN's server config file:
#
#script-security 2
#up /etc/openvpn/up.sh
#client-config-dir "/etc/openvpn"

/bin/rm /tmp/client-routes-ip*

MOSTPOPULAR=$(/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|ФСКН|Генпрокуратура|суд|rutracker\.org)'| awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" | awk -F. '{print $1"\\."$2"\\."$3}' | sort -nr | uniq -c | sort -nr | /bin/grep -E --colour=none -v "\s(1|2)\s" | awk '{print $2}' | tr '\n' '|')


/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|Генпрокуратура|суд|ФСКН|rutracker\.org)'| /bin/grep -E --colour=none -iv "(${MOSTPOPULAR::-1}|casino|slot|777|bet|intim|prostitu|kazin|volca|vulka|diplom)" | awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" >> /tmp/client-routes-ips


cat  /tmp/client-routes-ips |  uniq  |
while read configfile; do

echo $configfile | sed -e 's/^/push\ "route\ /' -e 's/$/"/' >> /tmp/client-routes-ips-sorted;
done;

/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|Генпрокуратура|суд|ФСКН|rutracker\.org)' | awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" | awk -F. '{print $1"."$2"."$3}' | sort -nr | uniq -c | sort -nr | /bin/grep -E --colour=none -v "\s(1|2)\s" | awk '{print "push \"route "$2".0 255.255.255.0\""}' >> /tmp/client-routes-ips-sorted;


/bin/cat /tmp/client-routes-ips-sorted | sed 's/push "route /ip route add /' | sed 's/ 255.255.255.0"/\/24 dev tunipsec table 128/' | sed 's/"/\/32 dev tunipsec table 128/' | sh


