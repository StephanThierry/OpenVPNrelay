# OpenVPN Static IP Relay
Setting up an OpenVPN server for public/external IP address relay. This will allow support consultants to use static/whitelisted IP from either home, office or at customer site.  

On AWS this can run on a t3.nano at a price of about 3.75$/month making this service quite affordable. Buying a 1y-Reserved Instance (AWS RI) of a t3.nano, will bring the price down to about 26$/year.  

If you are using the included scripts you need to make them executable first:  
`sudo chmod +x 01_OpenVPNserver_install.sh`  
`sudo chmod +x 02_IpTableRules.sh`  
And then run them:  
`sudo ./01_OpenVPNserver_install.sh`  
`sudo ./02_IpTableRules.sh`  

## Setup OpenVPN IP relay on Ubuntu 18.04  

Show public IP (this will be used during the OpenVPN server installation):  
`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com`

Download OpenVPN:  
`sudo wget https://git.io/vpn -O openvpn-install.sh`    

Run installer:  
`sudo bash openvpn-install.sh`  

* Enter public IP - Accept default port - Select Google DNS  

The installation will tell you where the client certificate is located. If you've use the default client-name it will be: `/home/ubuntu/client.ovpn`.  
Copy that to a local .ovpn file on your workstation `MyConnection.ovpn` - one option is to show it on the screen and copy-paste it into a local file using: `cat /home/ubuntu/client.ovpn`   

**Setup iptables:**

Delete existing rules (I'm not sure why this is nessesary, but I have tested the configuration twice and both times it would not work until I did it.):  
```
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
```

Setup Network Address Translation (NAT):    
`sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE`   

Now you can test the setup and if it's working you can set all other iptable/firewall restrictions you need on the server.  

Install iptables-persistent, it will save iptable rules after install is done:  
`sudo apt-get install iptables-persistent`  


**DNS settings**
If everything is connecting correctly, but you can't get DNS to work (Like if you `ping facebook.com` and you get the error: `Ping request could not find host facebook.com.`) ensure that these 2 lines are in your server.conf file.  
`push "dhcp-option DNS 8.8.8.8"` 
`push "dhcp-option DNS 8.8.4.4"` 
You can access the .conf file using: `sudo vim /etc/openvpn/server/server.conf`

## Change login type to username / password  
**Server**  
Edit the server.conf file  
`sudo vim /etc/openvpn/server/server.conf`  
If your .conf file is elsewhere - find it using:  `cd / && sudo find -name server.conf`    
Delete or comment out (adding # in front of): `auth`, `tls-auth`, `cipher` and `crl-verify`  

Add: 
`client-cert-not-required`  
`plugin  /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login`  
`username-as-common-name`  

**Note!** On other versions of Linux the `openvpn-plugin-auth-pam.so` file may have another name and be located elsewhere. Like "/usr/lib/openvpn/openvpn-auth-pam.so", "/usr/share/openvpn/plugin/lib/openvpn-auth-pam.so" etc.  You can likely find it using: `cd / && sudo find -name *pam.so`   

**Client**  
In your client .ovpn file delete or comment out: 
`auth` and `cipher`  
Add:  
`auth-user-pass` 

### Add users
Now you need to add the users:  
`sudo adduser [username]` and set password: `sudo passwd [username]`  

Now the users should be able to connect using the certificate (.ovpn-file) and their username/password.  

Note. If you get this error:  `Please enter a username matching the regular expression configured`  you can edit that regex in `/etc/adduser.conf` or you can use: the --force-badname option like so: `sudo adduser [username] --force-badname`  

 
