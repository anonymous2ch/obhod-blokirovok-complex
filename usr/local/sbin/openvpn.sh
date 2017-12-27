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

rm -f /tmp/client-routes-*
rm -f /etc/openvpn/DEFAULT

#Uncomment this lines to actually resolve every single host (need gnu parallel and still very slow)
#curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | awk -F\; {'print $3'} | sed 's/\ |\ /\n/g' | egrep 'http(s)?'| sed  -r 's/http(s)?:\/\///' | awk -F\/ '{print $1}' | iconv -f cp1251 -t utf8 | uniq | sed -r 's/\.$//'  | sed -r 's/http(s)?\:\/\///' | sed -r 's/^([^/]*?).*$/\1/i' | uniq | grep -P '(?:[a-z\x{00a1}\x{ffff}0-9]-*)*[a-z\x{00a1}-\x{ffff}0-9]+$' | sort | uniq >> $TEMPDIR/client-routes-hostnames-nonunique;
#cat $TEMPDIR/client-routes-hostnames-nonunique | sort | uniq > $TEMPDIR/client-routes-hostnames
#cat $TEMPDIR/client-routes-hostnames  sort | uniq | parallel -j250 "host {}  |  grep 'has address' | sed -e 's/.*\ has\ address\ //' | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | tee -a $TEMPDIR/client-routes-ips-resolved | tr '\n' ' ' |sed -e 's/^/{}\ /' -e 's/$/\n/' >>/etc/openvpn/client-routes-cache"

MOSTPOPULAR=$(/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|Генпрокуратура|суд|rutracker\.org)'| awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" | awk -F. '{print $1"\\."$2"\\."$3}' | sort -nr | uniq -c | sort -nr | /bin/grep -E --colour=none -v "\s(1|2)\s" | awk '{print $2}' | tr '\n' '|')

#/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv |  /usr/bin/iconv -f cp1251 -t utf8 | egrep -e '(Роскомнадзор|Генпрокуратура|rutracker\.org)'| egrep -iv '(${MOSTPOPULAR::-1}|jpg|image|sex|loli|porn|teen|hentai|xxx|video|galler|png|gif|jpeg|swf|girls|young|manga|henta|graniru\.info|casino|derpibooru|e621|sankakucomplex|youtube|pixiv|booru)' | awk -F\; {'print $3'} | sed 's/\ |\ /\n/g' | egrep 'http(s)?'| sed  -r 's/http(s)?:\/\///' |  awk -F\/ '{print $1}' | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >/tmp/client-routes-ips

/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|Генпрокуратура|суд|rutracker\.org)'| /bin/grep -E --colour=none -iv "(${MOSTPOPULAR::-1}|jpg|image|sex|loli|porn|teen|hentai|xxx|video|galler|png|gif|jpeg|swf|girls|young|manga|henta|graniru\.info|casino|derpibooru|e621|sankakucomplex|youtube|pixiv|booru|slot|777|bet|intim|prostitu|kazin|volca|vulka|diplom)" | awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" >> /tmp/client-routes-ips

#Some wierd bug makes OpenVPN correctly interpret line with no more than 255 chars, so we have to split all our ips to a million of files. Uncomment this line in case they fix the bug
#cat $TEMPDIR/client-routes-ips-resolved /$TEMPDIR/client-routes-ips |  uniq  | tr '\n' ' ' | sed -e "s/^/push\ 'route\ /" -e "s/\ $/'\n/" > /etc/openvpn/DEFAULT


cat  /tmp/client-routes-ips |  uniq  |
while read configfile; do

echo $configfile | sed -e 's/^/push\ "route\ /' -e 's/$/"/' >> /etc/openvpn/DEFAULT;
done;

/usr/bin/curl -s https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | /usr/bin/iconv -f cp1251 -t utf8 | /bin/grep -E --colour=none '(Роскомнадзор|Генпрокуратура|суд|rutracker\.org)' | awk -F\; {'print $1'} | tr '| ' '\n' | sort -nr |uniq | /bin/grep -E --colour=none "^([0-9]{1,3}[\.]){3}[0-9]{1,3}$" | awk -F. '{print $1"."$2"."$3}' | sort -nr | uniq -c | sort -nr | /bin/grep -E --colour=none -v "\s(1|2)\s" | awk '{print "push \"route "$2".0 255.255.255.0\""}' >> /etc/openvpn/DEFAULT;

echo 'push "route 104.25.224.38 255.255.255.255"' >> /etc/openvpn/DEFAULT
echo 'push "route 104.25.223.38 255.255.255.255"' >> /etc/openvpn/DEFAULT

chown openvpn:openvpn /etc/openvpn/DEFAULT
chown openvpn:openvpn /tmp/client-routes-*