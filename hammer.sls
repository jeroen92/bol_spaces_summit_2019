##
#   ==== USERS
##

user_root:
    user.present:
    - password: $1$C2ta/cZC$99vKpE8IvDfPXLlc1NL6E/
    - name: root

##
#   ==== PACKAGES
##

dem_packages:
    pkg.installed:
    - pkgs:
        - dnsmasq
        - hostapd
        - dhcp
        - nginx

##
#   ==== SYSTEM CONFIG
##

network_wlan0:
    network.managed:
    - name: wlan0
    - type: eth
    - enable: True
    - ipaddr: 10.0.0.1
    - netmask: 255.255.255.0
    - enable_ipv6: false

##
#   ==== CONFIG FILES
##

hostapd_config:
    file.managed:
    - source: salt://files/hostapd.conf
    - name: /etc/hostapd/hostapd.conf

dhcp_config:
    file.managed:
    - source: salt://files/dhcpd.conf
    - name: /etc/dhcp/dhcpd.conf

nginx_config:
    file.managed:
    - source: salt://files/nginx.conf
    - name: /etc/nginx/nginx.conf
    - user: nginx
    - group: nginx
    - mode: 600

var_www:
    file.directory:
    - name: /var/www/nginx
    - makedirs: True
    - user: nginx
    - group: nginx
    - dir_mode: 550
    - file_mode: 550
    - recurse:
        - user
        - group
        - mode

var_www_index:
    file.managed:
    - name: /var/www/index.html
    - source: salt://files/index.html
    - user: nginx
    - group: nginx
    - mode: 500

dnsmasq_hosts:
    file.managed:
    - source: salt://files/dnsmasq.hosts
    - name: /etc/dnsmasq.hosts
    - user: nobody
    - group: nobody
    - mode: 655

dnsmasq_config:
    file.managed:
    - source: salt://files/dnsmasq.conf
    - name: /etc/dnsmasq.conf
    - user: nobody
    - group: nobody
    - mode: 550

##
#   ==== SERVICES
##

service_hostapd:
    service.running:
    - name: hostapd
    - enable: True
    - watch:
        - file: hostapd_config

service_dhcpd:
    service.running:
    - name: dhcpd
    - enable: True
    - watch:
        - file: dhcp_config

service_nginx:
    service.running:
    - name: nginx
    - enable: True
    - watch:
        - file: nginx_config

service_dnsmasq:
    service.running:
    - name: dnsmasq
    - enable: True
    - watch:
        - file: dnsmasq_config

##
#   ==== FIREWALLING
##

firewalld_dns:
    firewalld.service:
    - name: dns
    - ports:
        - 53/udp
        - 53/tcp

firewalld_http:
    firewalld.service:
    - name: http
    - ports:
        - 80/tcp

firewalld_ssh:
    firewalld.service:
    - name: ssh
    - ports:
        - 22/tcp

firewalld_zone_public:
    firewalld.present:
    - name: public
    - services:
        - dns
        - http
        - ssh
    - sources:
        - 10.0.0.0/24
