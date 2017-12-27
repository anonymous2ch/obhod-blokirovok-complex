iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -N VPN_FORWARD
iptables -N VPN_INPUT
iptables -A INPUT -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -A INPUT -s 192.168.123.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.222.0/24 -j ACCEPT
iptables -A INPUT -i tunipsec -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT
iptables -A INPUT -i tunopenvpn -j ACCEPT
iptables -A INPUT -i eth0 -m policy --dir in --pol ipsec -j VPN_INPUT
iptables -A INPUT -i tunopenvpn -j ACCEPT
iptables -A INPUT -i tunipsec -j ACCEPT
iptables -A INPUT -j DROP
iptables -A FORWARD -d 192.168.123.0/24 -j ACCEPT
iptables -A FORWARD -d 10.0.1.0/24 -j ACCEPT
iptables -A FORWARD -d 10.222.1.0/24 -j ACCEPT
iptables -A FORWARD -d 192.168.222.0/24 -j ACCEPT
iptables -A FORWARD -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -A FORWARD -m policy --dir in --pol ipsec --proto esp -j ACCEPT
iptables -A FORWARD -i tunipsec -j ACCEPT
iptables -A FORWARD -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -A FORWARD -i eth0 -m policy --dir in --pol ipsec -j VPN_FORWARD
iptables -A FORWARD -i tunopenvpn -j ACCEPT
iptables -A FORWARD -o tunopenvpn -j ACCEPT
iptables -A FORWARD -i tunipsec -j ACCEPT
iptables -A FORWARD -o tunipsec -j ACCEPT
iptables -A FORWARD -i tunipsec -o tunopenvpn -j ACCEPT
iptables -A FORWARD -i tunipsec -o br0 -j ACCEPT
iptables -A FORWARD -i tunopenvpn -o tunipsec -j ACCEPT
iptables -A FORWARD -i tunopenvpn -o br0 -j ACCEPT
iptables -A FORWARD -i br0 -o tunipsec -j ACCEPT
iptables -A FORWARD -i br0 -o tunopenvpn -j ACCEPT
iptables -A FORWARD -i tunopenvpn -o tunopenvpn -j ACCEPT
iptables -A FORWARD -i tunipsec -o tunipsec -j ACCEPT
iptables -A FORWARD -j DROP
iptables -A OUTPUT -d 192.168.123.0/24 -j ACCEPT
iptables -A OUTPUT -d 10.0.1.0/24 -j ACCEPT
iptables -A OUTPUT -d 10.222.1.0/24 -j ACCEPT
iptables -A OUTPUT -d 192.168.222.0/24 -j ACCEPT
iptables -A OUTPUT -m policy --dir out --pol ipsec --proto esp -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -A OUTPUT -f -j DROP
iptables -A OUTPUT -j ACCEPT
iptables -A VPN_FORWARD -s 10.222.1.0/24 -j ACCEPT
iptables -A VPN_FORWARD -s 192.168.123.0/24 -j ACCEPT
iptables -A VPN_FORWARD -s 10.0.1.0/24 -j ACCEPT
iptables -A VPN_FORWARD -s 192.168.222.0/24 -j ACCEPT
iptables -A VPN_FORWARD -j DROP
iptables -A VPN_INPUT -s 10.222.1.0/24 -j ACCEPT
iptables -A VPN_INPUT -s 192.168.123.0/24 -j ACCEPT
iptables -A VPN_INPUT -s 10.0.1.0/24 -j ACCEPT
iptables -A VPN_INPUT -s 192.168.222.0/24 -j ACCEPT
iptables -A VPN_INPUT -j DROP

iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P INPUT ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -A PREROUTING -d 123.123.123.123/32 -i tunopenvpn -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3129
iptables -t nat -A PREROUTING -s 192.168.222.0/24 -d 123.123.123.123/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 192.168.222.0/24 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 10.222.1.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 192.168.222.0/24 ! -d 192.168.222.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 10.0.1.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 10.0.1.0/24 -d 123.123.123.123/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 192.168.123.0/24 ! -d 10.222.1.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 10.222.1.1:53
iptables -t nat -A PREROUTING -s 192.168.123.0/24 -d 123.123.123.123/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -s 192.168.123.0/24 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.222.1.1:3129
iptables -t nat -A PREROUTING -i eth0 -m policy --dir in --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 ! -d 10.222.1.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.123.0/24 ! -d 10.222.1.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.222.1.0/24 ! -d 10.222.1.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.222.0/24 ! -d 192.168.222.0/24 -o eth0 -j MASQUERADE


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
iptables -I OUTPUT -d 192.168.222.0/24 -j ACCEPT
iptables -I OUTPUT -d 10.222.1.0/24 -j ACCEPT
iptables -I OUTPUT -d 10.0.1.0/24 -j ACCEPT
iptables -I OUTPUT -d 192.168.123.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.222.0/24 -j ACCEPT
iptables -I FORWARD -d 10.222.1.0/24 -j ACCEPT
iptables -I FORWARD -d 10.0.1.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.123.0/24 -j ACCEPT
