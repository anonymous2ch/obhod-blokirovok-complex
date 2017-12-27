/interface 6to4
add comment="Hurricane Electric IPv6 Tunnel Broker" !keepalive local-address=\
    41.4.5.6 mtu=1430 name=HEIPv6 remote-address=216.66.80.90
/interface gre
add dont-fragment=inherit !keepalive local-address=41.4.5.6 mtu=1380 \
    name=tunipsec remote-address=188.1.2.3
/ip ipsec mode-config
add name=foreign system-dns=no
/ip ipsec policy group
add name=foreign
/ip ipsec proposal
set [ find default=yes ] auth-algorithms=sha1,md5 enc-algorithms=\
    aes-128-cbc,3des,des lifetime=1h
/ip pool
add name=FreeWiFi ranges=10.123.123.10-10.123.123.200
/ip dhcp-server
add address-pool=FreeWiFi authoritative=after-2sec-delay disabled=no \
    interface=FreeWiFi lease-time=1h name=FreeWiFi
/ipv6 dhcp-server
add address-pool=2001:470:12:678::/64 interface=LANbridge name=server1
add address-pool=FreeWiFi interface=FreeWiFi name=FreeWiFi
/ipv6 pool
add name=2001:470:12:678::/64 prefix=2001:470:12:678::/64 prefix-length=64
add name=FreeWiFi prefix=2001:470:abcd:1::/64 prefix-length=64
/queue simple
add burst-limit=4M/4M burst-threshold=1M/1M burst-time=15s/15s max-limit=\
    2M/2M name=FreeWiFi target=10.123.123.0/24,FreeWiFi time=\
    0s-1d,sun,mon,tue,wed,thu,fri,sat
/queue interface
set LocalLAN queue=ethernet-default
set carrier queue=default
/queue tree
add disabled=yes name=HTTP-Queue packet-mark=HTTP-Marked parent=LANbridge \
    priority=2 queue=default
/routing bgp instance
set default as=64496 client-to-client-reflection=no router-id=192.168.222.2
/interface bridge port
add bridge=LANbridge hw=no interface=LocalLAN
add bridge=LANbridge hw=no interface=wlan1
/ip firewall connection tracking
set generic-timeout=30m icmp-timeout=50s tcp-close-timeout=30s \
    tcp-close-wait-timeout=30s tcp-established-timeout=30m \
    tcp-fin-wait-timeout=30s tcp-last-ack-timeout=30s \
    tcp-max-retrans-timeout=15m tcp-syn-received-timeout=15s \
    tcp-syn-sent-timeout=15s tcp-time-wait-timeout=30s tcp-unacked-timeout=\
    15m udp-stream-timeout=15m udp-timeout=1m
/ip settings
set arp-timeout=1m30s rp-filter=strict secure-redirects=no send-redirects=no \
    tcp-syncookies=yes
/ipv6 settings
set max-neighbor-entries=1024
/ip address
add address=41.4.5.6/24 interface=carrier network=41.4.5.0
add address=192.168.123.1/24 interface=LANbridge network=192.168.123.0
add address=192.168.222.2/24 interface=tunipsec network=192.168.222.0
add address=10.123.123.1/24 interface=FreeWiFi network=10.123.123.0
/ip dhcp-server
add address-pool=dhcp authoritative=after-2sec-delay disabled=no interface=\
    LANbridge lease-time=10h10m name=dhcp
/ip dhcp-server network
add address=10.123.123.0/24 dns-server=10.123.123.1,8.8.8.8 gateway=10.123.123.1 \
    netmask=24
add address=192.168.123.0/24 dns-server=10.222.1.1,8.8.8.8,192.168.123.1 \
    gateway=192.168.123.1 netmask=24
/ip dns
set allow-remote-requests=yes servers=10.222.1.1,8.8.8.8,2001:470:1002:123::2
/ip firewall address-list
add address=87.240.128.0/18 list=vk.com
add address=93.186.224.0/20 list=vk.com
add address=95.142.192.0/20 list=vk.com
add address=95.213.0.0/17 list=vk.com
add address=185.32.248.0/22 list=vk.com
/ip firewall filter
add action=accept chain=input protocol=icmp
add action=accept chain=forward disabled=yes routing-mark=http
add action=accept chain=forward disabled=yes src-address-list=http-hosts
add action=accept chain=input disabled=yes routing-mark=http
add action=accept chain=input src-address=192.168.222.0/24
add action=accept chain=input in-interface=LANbridge src-address=\
    192.168.123.0/24
add action=accept chain=input src-address=192.168.222.0/24
add action=accept chain=input dst-port=179 protocol=tcp src-address=\
    192.168.222.0/24
add action=accept chain=input dst-address=10.123.123.1 dst-port=53 \
    in-interface=FreeWiFi protocol=udp src-address=10.123.123.0/24
add action=reject chain=input connection-state=established,related \
    dst-address=10.123.123.1 in-interface=FreeWiFi reject-with=\
    icmp-port-unreachable src-address=10.123.123.0/24
add action=drop chain=forward dst-address=10.0.0.0/8 src-address=\
    10.123.123.0/24
add action=drop chain=forward dst-address-list=vk.com src-address=\
    10.123.123.0/24
add action=drop chain=forward connection-state="" dst-address=192.168.0.0/16 \
    src-address=10.123.123.0/24
add action=accept chain=output connection-state=established dst-address=\
    10.123.123.0/24
add action=accept chain=output connection-state=related dst-address=\
    10.123.123.0/24
add action=drop chain=output connection-state="" dst-address=10.0.0.0/8 \
    src-address=10.123.123.0/24
add action=drop chain=input connection-state="" dst-address=10.0.0.0/8 \
    src-address=10.123.123.0/24
add action=accept chain=input in-interface=FreeWiFi protocol=icmp \
    src-address=10.123.123.0/24
add action=accept chain=forward in-interface=FreeWiFi out-interface=carrier \
    src-address=10.123.123.0/24
add action=accept chain=input connection-state=established,related \
    in-interface=FreeWiFi src-address=10.123.123.0/24
add action=accept chain=input src-address=192.168.222.0/24
add action=accept chain=input port=179 protocol=tcp
add action=accept chain=input in-interface=tunipsec
add action=accept chain=input protocol=ipsec-esp
add action=accept chain=input protocol=ipsec-ah
add action=accept chain=input dst-port=500 protocol=udp
add action=accept chain=input dst-port=4500 protocol=udp
add action=accept chain=input protocol=gre
add action=accept chain=output
add action=accept chain=output connection-state=established,related,new \
    out-interface=carrier
add action=accept chain=input src-address=188.1.2.3
add action=accept chain=input src-address=10.222.1.0/24
add action=accept chain=forward out-interface=LANbridge src-address=\
    10.222.1.0/24
add action=accept chain=forward src-address=192.168.123.0/24
add action=accept chain=input dst-address=192.168.222.0/31
add action=accept chain=output dst-address=192.168.222.0/31
add action=accept chain=forward src-address=192.168.222.0/31
add action=accept chain=input connection-state=established,related \
    dst-address=41.4.5.6 in-interface=carrier
add action=accept chain=output dst-address=188.1.2.3
add action=accept chain=input connection-state=\
    established,related,new,untracked in-interface=tunipsec
add action=drop chain=input dst-address=41.4.5.6 in-interface=carrier
add action=accept chain=forward in-interface=tunipsec
add action=accept chain=input protocol=icmp
add action=accept chain=output protocol=icmp
add action=fasttrack-connection chain=output out-interface=carrier src-address=\
    192.168.123.0/24
add action=fasttrack-connection chain=forward comment=\
    "defconf: accept established,related" connection-state=\
    established,related ipv4-options=strict-source-routing out-interface=\
    carrier src-address=192.168.123.0/24
add action=fasttrack-connection chain=forward out-interface=carrier \
    src-address=10.123.123.0/24
add action=fasttrack-connection chain=output out-interface=carrier src-address=\
    10.123.123.0/24
add action=fasttrack-connection chain=forward comment=\
    "defconf: accept established,related" connection-state=\
    established,related ipv4-options=strict-source-routing out-interface=\
    tunipsec src-address=192.168.123.0/24
add action=fasttrack-connection chain=forward comment=\
    "defconf: accept established,related" connection-state=\
    established,related ipv4-options=strict-source-routing out-interface=\
    tundeloks src-address=192.168.123.0/24
add action=fasttrack-connection chain=forward out-interface=tunipsec \
    src-address=10.123.123.0/24
add action=fasttrack-connection chain=forward out-interface=tundeloks \
    src-address=10.123.123.0/24
add action=accept chain=input connection-state=established dst-address=\
    192.168.123.0/24 in-interface=carrier
add action=accept chain=input connection-state=related dst-address=\
    192.168.123.0/24 in-interface=carrier ipv4-options=strict-source-routing
add action=accept chain=input dst-address=192.168.123.0/24 protocol=icmp
add action=accept chain=forward out-interface=LANbridge
add action=accept chain=forward out-interface=FreeWiFi
add action=accept chain=forward in-interface=LANbridge
add action=accept chain=forward in-interface=FreeWiFi
add action=drop chain=input in-interface=carrier src-address=10.0.0.0/8
add action=drop chain=input in-interface=carrier src-address=172.0.0.0/16
add action=drop chain=forward in-interface=carrier src-address=10.0.0.0/8
add action=drop chain=forward in-interface=carrier src-address=172.0.0.0/16
add action=drop chain=forward comment=\
    "defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface=carrier ipv4-options=\
    strict-source-routing
add action=drop chain=input
add action=drop chain=forward
add action=accept chain=output
add action=accept chain=input
/ip firewall mangle
add action=mark-routing chain=prerouting dst-address-list=vk.com \
    new-routing-mark=vk.com passthrough=yes src-address=10.123.123.0/24
add action=change-mss chain=forward disabled=yes in-interface=LANbridge \
    new-mss=1200 out-interface=tunipsec passthrough=yes protocol=tcp \
    tcp-flags=syn
add action=accept chain=forward in-interface=LANbridge out-interface=\
    tunipsec tcp-flags=""
add action=add-dst-to-address-list address-list=http-hosts \
    address-list-timeout=none-dynamic chain=prerouting comment="Mark HTTP" \
    disabled=yes dst-port=80 protocol=tcp src-address=192.168.123.0/24
add action=mark-connection chain=prerouting comment="Mark HTTP" disabled=yes \
    dst-port=80 new-connection-mark=HTTP-Conn passthrough=yes protocol=tcp \
    src-address=192.168.123.0/24
add action=mark-connection chain=prerouting comment="Mark HTTP" disabled=yes \
    new-connection-mark=HTTP-Conn passthrough=yes src-address-list=http-hosts
add action=mark-connection chain=prerouting comment="Mark HTTP" disabled=yes \
    dst-address-list=http-hosts new-connection-mark=HTTP-Conn passthrough=yes
add action=mark-connection chain=prerouting comment="Mark HTTP" disabled=yes \
    dst-address=192.168.123.0/24 new-connection-mark=HTTP-Conn passthrough=\
    yes protocol=tcp src-port=80
add action=mark-packet chain=prerouting connection-mark=HTTP-Conn disabled=\
    yes new-packet-mark=HTTP-Marked passthrough=yes
add action=mark-routing chain=prerouting connection-mark=HTTP-Conn disabled=\
    yes new-routing-mark=http passthrough=yes
add action=mark-routing chain=prerouting disabled=yes new-routing-mark=http \
    packet-mark=HTTP-Marked passthrough=yes
add action=mark-routing chain=prerouting disabled=yes dst-address-list=\
    http-hosts new-routing-mark=http passthrough=yes
add action=mark-routing chain=prerouting disabled=yes new-routing-mark=http \
    passthrough=yes src-address-list=http-hosts
add action=fasttrack-connection chain=forward connection-mark=HTTP-Conn \
    connection-state=established,related,new disabled=yes protocol=tcp \
    tcp-flags=""
/ip firewall nat
add action=accept chain=srcnat dst-address=10.222.1.0/24 src-address=\
    192.168.123.0/24
add action=accept chain=srcnat dst-address=192.168.222.0/24 src-address=\
    192.168.123.0/24
add action=accept chain=srcnat routing-mark=vk.com src-address=10.123.123.0/24
add action=masquerade chain=srcnat out-interface=carrier routing-mark=!http
add action=masquerade chain=srcnat fragment=yes out-interface=tunipsec
/ip firewall raw
add action=notrack chain=output out-interface=tunipsec
/ip ipsec peer
add address=188.1.2.3/32 auth-method=rsa-signature certificate=\
    mikrotik.crt_0 comment=tunipsec dh-group=modp1024 exchange-mode=ike2 \
    hash-algorithm=md5 lifetime=1h local-address=41.4.5.6 notrack-chain=\
    output policy-template-group=foreign remote-certificate=strongswan.crt_0
/ip ipsec policy
set 0 disabled=yes
add comment=tunipsec dst-address=188.1.2.3/32 protocol=gre src-address=\
    41.4.5.6/32
/ip pool
add name=dhcp next-pool=dhcp ranges=192.168.123.3-192.168.123.254
/ip route
add disabled=yes distance=1 gateway=tunipsec routing-mark=http scope=40
add distance=1 dst-address=87.240.128.0/18 routing-mark=vk.com type=blackhole
add distance=1 dst-address=93.186.224.0/20 routing-mark=vk.com type=blackhole
add distance=1 dst-address=95.142.192.0/20 routing-mark=vk.com type=blackhole
add distance=1 dst-address=95.213.0.0/17 routing-mark=vk.com type=blackhole
add distance=1 dst-address=185.32.248.0/22 routing-mark=vk.com type=blackhole
add distance=44 gateway=41.4.5.1 pref-src=41.4.5.6 scope=40
add bgp-as-path=65000 bgp-origin=igp disabled=yes distance=4 dst-address=\
    8.8.8.8/32 gateway=tunipsec scope=40
add distance=1 dst-address=10.222.1.0/24 gateway=tunipsec
add distance=1 dst-address=10.222.1.0/24 gateway=tunipsec
add check-gateway=ping distance=1 dst-address=123.123.123.123/32 gateway=\
    tunipsec
/ip route rule
add disabled=yes routing-mark=http table=http
/ipv6 address
add address=2001:470:11:678::2 advertise=no interface=HEIPv6
add address=2001:470:abcd:1::1 interface=FreeWiFi
add address=2001:470:abcd:2::1 interface=LANbridge
/ipv6 firewall filter
add action=accept chain=forward
add action=accept chain=input
add action=accept chain=output
/ipv6 nd
set [ find default=yes ] advertise-dns=yes interface=LANbridge \
    managed-address-configuration=yes other-configuration=yes
add advertise-mac-address=no interface=FreeWiFi
/ipv6 route
add distance=1 dst-address=2000::/3 gateway=2001:470:11:678::1
/routing bgp network
add network=192.168.222.0/24 synchronize=no
/routing bgp peer
add hold-time=6m keepalive-time=20s name=192.168.222.2 remote-address=\
    192.168.222.1 remote-as=65000 tcp-md5-key=SuperPassword123 ttl=default \
    update-source=tunipsec
/routing prefix-lists
add action=discard chain=deny-default disabled=yes
add chain=accept
/routing rip
set garbage-timer=30m metric-bgp=10 metric-connected=10 metric-default=10 \
    metric-ospf=10 metric-static=10 timeout-timer=30m update-timer=15m