ip6tables -P OUTPUT ACCEPT
ip6tables -P INPUT ACCEPT
ip6tables -A OUTPUT -o he-ipv6 -j ACCEPT
ip6tables -A INPUT -i tunopenvpn -j ACCEPT
iptables -I INPUT -i tunipsec -j ACCEPT
iptables -I FORWARD -i tunipsec -j ACCEPT
iptables -t nat -A PREROUTING -s 192.168.222.0/24 -d 123.123.123.123/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 192.168.222.0/24 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -A INPUT -p gre -j ACCEPT
iptables -I INPUT -s 192.168.123.0/24 -j ACCEPT
iptables -I INPUT -s 192.168.222.0/24 -j ACCEPT
iptables -I OUTPUT -d 192.168.222.0/24 -j ACCEPT
ip6tables -D INPUT -j DROP
ip6tables -D OUTPUT -j DROP

ip6tables -A INPUT -i he-ipv6 -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -o he-ipv6 -m state --state NEW,ESTABLISHED,RELATED,INVALID -j ACCEPT

# allow incoming ICMP ping pong stuff
ip6tables -A INPUT -i he-ipv6 -p ipv6-icmp -j ACCEPT
ip6tables -A OUTPUT -o he-ipv6 -p ipv6-icmp -j ACCEPT
ip6tables -A INPUT -i he-ipv6 -j DROP

#i2p & onion forwarding

iptables -t nat -I PREROUTING -i tunopenvpn -d 123.123.123.123 -p tcp --dport 80 -j REDIRECT --to-port 3129

iptables -t nat -A PREROUTING -s 10.222.1.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53

iptables -t nat -A PREROUTING -s 192.168.222.0/24 ! -d 192.168.222.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53

iptables -t nat -A PREROUTING -s 10.0.1.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 10.0.1.0/24 -d 123.123.123.123 -p tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 ! -d 10.222.1.0/24 -o eth0 -j MASQUERADE

iptables -t nat -A PREROUTING -s 192.168.123.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 192.168.123.0/24 -d 123.123.123.123 -p tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 192.168.123.0/24 -p tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A POSTROUTING -s 192.168.123.0/24 ! -d 10.222.1.0/24 -o eth0 -j MASQUERADE

ip route add 123.123.123.123 via 127.0.0.1 dev lo

iptables -A INPUT -i tunopenvpn -j ACCEPT
iptables -I INPUT -s 192.168.123.0/24 -j ACCEPT

iptables -I INPUT  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -I FORWARD  -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -I FORWARD  -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -I OUTPUT   -m policy --dir out --pol ipsec --proto esp -j ACCEPT

iptables -I FORWARD -d 192.168.100.1/32 -j ACCEPT
iptables -I LAN_INET_FORWARD_CHAIN -d 172.16.0.0/12 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 192.168.0.0/16 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 172.16.0.0/12 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 10.0.0.0/8 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 100.64.0.0/10 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 169.254.0.0/16 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 198.18.0.0/15 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 198.51.100.0/24 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 203.0.113.0/24 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 224.0.0.0/4 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 240.0.0.0/4 -j DROP
iptables -I LAN_INET_FORWARD_CHAIN -d 192.168.222.0/24 -j ACCEPT
iptables -I LAN_INET_FORWARD_CHAIN -d 10.222.1.0/24 -j ACCEPT
iptables -I LAN_INET_FORWARD_CHAIN -d 10.0.1.0/24 -j ACCEPT
iptables -I LAN_INET_FORWARD_CHAIN -d 192.168.100.0/24 -j ACCEPT
iptables -I LAN_INET_FORWARD_CHAIN -d 192.168.123.0/24 -j ACCEPT
iptables -I EXT_FORWARD_OUT_CHAIN -d 172.16.0.0/12 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 192.168.0.0/16 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 172.16.0.0/12 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 10.0.0.0/8 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 100.64.0.0/10 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 169.254.0.0/16 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 198.18.0.0/15 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 198.51.100.0/24 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 203.0.113.0/24 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 224.0.0.0/4 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 240.0.0.0/4 -j DROP
iptables -I EXT_FORWARD_OUT_CHAIN -d 192.168.222.0/24 -j ACCEPT
iptables -I EXT_FORWARD_OUT_CHAIN -d 10.222.1.0/24 -j ACCEPT
iptables -I EXT_FORWARD_OUT_CHAIN -d 192.168.100.0/24 -j ACCEPT
iptables -I EXT_FORWARD_OUT_CHAIN -d 192.168.123.0/24 -j ACCEPT
iptables -I OUTPUT -d 172.16.0.0/12 -j DROP
iptables -I OUTPUT -d 192.168.0.0/16 -j DROP
iptables -I OUTPUT -d 172.16.0.0/12 -j DROP
iptables -I OUTPUT -d 10.0.0.0/8 -j DROP
iptables -I OUTPUT -d 100.64.0.0/10 -j DROP
iptables -I OUTPUT -d 169.254.0.0/16 -j DROP
iptables -I OUTPUT -d 198.18.0.0/15 -j DROP
iptables -I OUTPUT -d 198.51.100.0/24 -j DROP
iptables -I OUTPUT -d 203.0.113.0/24 -j DROP
iptables -I OUTPUT -d 224.0.0.0/4 -j DROP
iptables -I OUTPUT -d 240.0.0.0/4 -j DROP
iptables -I OUTPUT -d 192.168.222.0/24 -j ACCEPT
iptables -I OUTPUT -d 10.222.1.0/24 -j ACCEPT
iptables -I OUTPUT -d 10.0.1.0/24 -j ACCEPT
iptables -I OUTPUT -d 192.168.100.0/24 -j ACCEPT
iptables -I OUTPUT -d 192.168.123.0/24 -j ACCEPT
iptables -I FORWARD -d 172.16.0.0/12 -j DROP
iptables -I FORWARD -d 192.168.0.0/16 -j DROP
iptables -I FORWARD -d 172.16.0.0/12 -j DROP
iptables -I FORWARD -d 10.0.0.0/8 -j DROP
iptables -I FORWARD -d 100.64.0.0/10 -j DROP
iptables -I FORWARD -d 169.254.0.0/16 -j DROP
iptables -I FORWARD -d 198.18.0.0/15 -j DROP
iptables -I FORWARD -d 198.51.100.0/24 -j DROP
iptables -I FORWARD -d 203.0.113.0/24 -j DROP
iptables -I FORWARD -d 224.0.0.0/4 -j DROP
iptables -I FORWARD -d 240.0.0.0/4 -j DROP
iptables -I FORWARD -d 192.168.222.0/24 -j ACCEPT
iptables -I FORWARD -d 10.222.1.0/24 -j ACCEPT
iptables -I FORWARD -d 10.0.1.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.123.0/24 -j ACCEPT
