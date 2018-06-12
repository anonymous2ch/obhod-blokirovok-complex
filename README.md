# obhod-blokirovok-complex

Configuration explanation
======================

Physical devices:
----------------------

Nice country without Putin or Internet Censorship:

1. Server (gentoo linux), has an external IP: `188.1.2.3`. It runs: `squid`, `polipo`, `tor`, `i2p`, `openvpn`, `strongswan`, `bird`, `dnsmasq` and `dante`
2. `6to4` tunnel service from https://tunnelbroker.net

My home apartment:

1. Hardware router [mikrotik hAP](https://mikrotik.com/product/RB951Ui-2nD), its external IP `41.4.5.6`
2. Home PC (Windows) connected to the router via ethernet-cable
3. Laptops, phones and other devices, connected to router via Wi-Fi with WPA2-PSK auth
4. Guest laptops, phones connected via Wi-Fi without auth (free Wi-Fi)

Another apartment (without mikrotik router):

1.  Home PC (Windows) connected to the Internet via any ordinary means. It has OpenVPN client, that while being a bit slow, will prevent censorship just as good.

Other:

1. Android phone, with [StrongSwan VPN](https://play.google.com/store/apps/details?id=org.strongswan.android)
2. Android phone(s) with Telegram

Network interfaces & their addresses):
---------------------------

Physical IPv4:

1. My internal home network (which is served by that mikrotik i mentioned earlier), wi-fi and ethernet interfaces are bridged. IP Address: `192.168.123.1`, subnet `192.168.123.0/24`
2. Free Wi-Fi for guests `10.123.123.1`, isolated subnet `10.123.123.0/24`
3. External IPv4-address, that is given to mikrotik by my ISP `41.4.5.6`
4. External IPv4-address of the VPS/Server in a country without censorship: `188.1.2.3`, linux device name: `eth0`

IPv6:

1. My internal home network - IP Address: `2001:470:abcd:2::1/64`, subnet `2001:470:abcd:2::/64`
2. Free Wi-Fi for guests `2001:470:abcd:1::1/64`, isolated subnet `2001:470:abcd:1::/64`
3. `6to4` tunnel from mikrotik, IPv6:`2001:470:11:678::2/64`, IPv4:`41.4.5.6`, tunnelbroker.net endpoint: IPv6:`2001:470:11:678::1`, IPv4:`216.66.80.90`, prefix: `2001:470:abcd::/48`, prefix: `2001:470:12:678::/64`
4. `6to4` tunnel on the VPS/Server in a country without censorship instead of native ipv6 (I don't like the way they write my name & surname into public whois database for native ipv6), linux device name: `he-ipv6`, IPv6:`2001:470:1001:123::2/64`, IPv4:`188.1.2.3`,  tunnelbroker.net endpoint IPv6:`2001:470:1001:123::1/64`, IPv4:`216.66.80.30`, prefix: `2001:470:1002:123::/64`

Virtual Networks & tunnels:

1. Tunnel between mikrotik and VPS/Server in a country without censorship (linux device name: `tunipsec`), Tunnel technology: GRE over IPSsec (`strongswan`), Serverside Address: `192.168.222.1`, mikrotikside address: `192.168.222.2`, subnet mask `255.255.255.0`
2. `OpenVPN` network on that VPS/Server (server address: `10.222.1.1`, linux device name: `tunopenvpn`) client ip addresses pool: (`10.222.1.10-254`), netmask `10.222.1.0/24`
3. Tunnel between mobile strongswan vpn and that VPS/Server in a country without censorship (`10.0.1.0/24`)

Misc Addresses:

1. Virtual IP for tor/i2p: `123.123.123.123`


That's all you might need for reading the configs...

How does it work:
1. Script `/usr/local/bin/bgp.sh` gets [csv-table with censored IP-addresses](https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv) puts them into kernel table #128, which is not used by the system when routing.
2. BGP Bird server monitors that table and sends them to Mikrotik (using local AS 65000 (Bird) and 64496 (Mikrotik))
3. Mikrotik has static routes to 8.8.8.8 и 8.8.4.4, via VPS/Server, which in turn intercepts DNS-queries and modifies them.
4. `dnsmasq` answers `123.123.123.123` for everything in `.onioin` and `.i2p` zone. Traffic to `123.123.123` is then intercepted via `squid`, which sends it to `Polipo`->`Tor Socks5 Proxy` or directly to `i2p https proxy` as needed

TODO: Add DN42


# obhod-blokirovok-complex

Описание конфигурации
======================

Физические устройства:
----------------------

Приличная страна без путина и роскомнадзора:

1. Сервер (gentoo), внешний IP этого сервера: `188.1.2.3`. На нём запущены: `squid`, `polipo`, `tor`, `i2p`, `openvpn`, `strongswan`, `bird`, `dnsmasq` и `dante`
2. Сервер от https://tunnelbroker.net который предоставляет `6to4` туннели

Моя квартира:

1. Роутер [mikrotik hAP](https://mikrotik.com/product/RB951Ui-2nD), внешний IP, предоставленный российским провайдером: `41.4.5.6`
2. Комп стационарный (Windows) подключенный к роутеру через ethernet-кабель
3. Мои ноутбуки, телефоны и прочее вайфае-говно, подключенное по воздуху с WPA2-PSK авторизацией
4. Устройства гостей соседей и прочих майоров, подключенные по бесплатному wi-fi без авторизации

Квартира друга:

1. Комп (windows) подключенный к обычному интеренету через обычный роутер. На комп установлен OpenVPN с прилагаемым конфигом, внешний IP не нужен, никаких требований особых нет.

Прочее:

1. Телефон на Android, с установленным [StrongSwan VPN](https://play.google.com/store/apps/details?id=org.strongswan.android)
2. Телефон с установленным Telegram

Адреса сетей и интерфейсов:
---------------------------

Физические IPv4:

1. Внутреняя сеть устройств моей квартиры (роутером которой выступает тот самый mikrotik), wi-fi и ethernet объединены в мост, адрес интерфейса на роутере: `192.168.123.1`, подсеть `192.168.123.0/24`
2. Бесплатный вайфай для людей, адрес интерфейса `10.123.123.1`, изолированная подсеть `10.123.123.0/24`
3. Внешний белый статический IPv4-адрес, выданный роутеру mikrotik провайдером: `41.4.5.6`
4. Внешний белый статический IPv4-адрес сервера в приличной стране: `188.1.2.3`, linux device name: `eth0`

IPv6:

1. Внутреняя сеть устройств моей квартиры - адрес интерфейса на роутере: `2001:470:abcd:2::1/64`, подсеть `2001:470:abcd:2::/64`
2. Бесплатный вайфай для людей, адрес интерфейса `2001:470:abcd:1::1/64`, изолированная подсеть `2001:470:abcd:1::/64`
3. Туннель `6to4` на роутере mikrotik, адрес на роутере IPv6:`2001:470:11:678::2/64`, IPv4:`41.4.5.6`, адрес шлюза у tunnelbroker.net IPv6:`2001:470:11:678::1`, IPv4:`216.66.80.90`, префикс `2001:470:abcd::/48`, префикс `2001:470:12:678::/64`
4. Туннель `6to4` на сервере в приличной стране вместо нативного ipv6 (в whois которого за каким-то хером написана ФИО клиента), linux device name: `he-ipv6`, адрес интерфейса: IPv6:`2001:470:1001:123::2/64`, IPv4:`188.1.2.3`, адрес шлюза у tunnelbroker.net IPv6:`2001:470:1001:123::1/64`, IPv4:`216.66.80.30`, префикс: `2001:470:1002:123::/64`

Виртуальные сети и туннели:

1. Сеть между роутером mikrotik и сервером в приличной стране (linux device name: `tunipsec`), технология GRE over IPSsec (`strongswan`), адрес сервера: `192.168.222.1`, адрес микротика: `192.168.222.2`, маска подсети `255.255.255.0`
2. Сеть между сервером `OpenVPN` (адрес: `10.222.1.1`, linux device name: `tunopenvpn`) и его клиентами (`10.222.1.10-254`), маска `10.222.1.0/24`
3. Сеть между мобильным телефоном c установленным strongswan vpn и сервером в приличной стране (`10.0.1.0/24`)

Служебные адреса:

1. Виртуальный адрес для работы с tor/i2p: `123.123.123.123`


Вводная для чтения конфигов у вас теперь есть...

Принципы работы:
1. Скрипт `/usr/local/bin/bgp.sh` качает [csv-версию выгрузки РКН](https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv) и парсит IP-адреса оттуда в таблицу #128, никак не используемую системой для работы.
2. Сервер BGP Bird настроен на мониторинг этой таблицы и трансляцию маршрутов оттуда на роутер Mikrotik (используются локальные AS 65000 (Bird) и 64496 (Mikrotik))
3. В Микротике настроены статичные маршруты к серверам гугла 8.8.8.8 и 8.8.4.4, через удалённый сервер, который в свою очередь настроен на перехват DNS-запросов и обработку их локально.
4. `dnsmasq` отвечает адресом `123.123.123.123` на все `.onioin` и `.i2p` адреса, на этом адресе. Траффик на этот адрес перехватывается и заворачивается в `squid`, который в свою очередь распределяет его в Polipo->Tor Socks5 Proxy или же напрямую в i2p https proxy

TODO: Более подробное описание принципов работы, комментарии конфигов и однострочники на bash/ansible, позволяющие всё это развернуть за 5 минут. Добавить DN42
