#!/bin/bash
dig TXT +short o-o.myaddr.l.google.com @ns1.google.com
wget https://git.io/vpn -O openvpn-install.sh
bash openvpn-install.sh
