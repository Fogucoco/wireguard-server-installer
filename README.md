Just run and have your wireguard server installed  
```bash
sudo apt install wget -y ; wget https://raw.githubusercontent.com/Fogucoco/wireguard-server-installer/refs/heads/main/install-wireguard.sh ; chmod +x install-wireguard.sh ; sudo ./install-wireguard.sh
```
You'll have two scripts at your folder:  
1. install-wireguard.sh  
To be honest you can delete it at this point, because it's already has been run and has no use but installation  
2. add-wg-user.sh  
It's automaticaly run at install-wireguard.sh. So don't run it twice :) Use it for creating new users. To run it use:
```bash
sudo ./add-wg-user.sh
```  
It will ask you how many users you want and put the new configs in /home/wireguard-client-configs/  
You can easily download them by running this at your local windows machine:
```bash
scp YOUR_USER@SERVER_IP:/home/wireguard-client-configs/CONFIG_NAME %USERPROFILE%\Desktop
```
CONFIG_NAME is user + number + .conf. The first user is always user2. If you've created just one then type user2.conf
