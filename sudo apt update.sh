
#-----------Update and Upgarde OS-----------
sudo apt update
sudo apt upgrade

#-----------Prevent the os from any auto-update-----------
sudo vi /etc/apt/apt.conf.d/20auto-upgrades
# Ensure everything is set to 0. If done correctly you'll have a file that looks like this:
# APT::Periodic::Update-Package-Lists "0"
# APT::Periodic::Download-Upgradeable-Packages "0"
# APT::Periodic::AutocleanInterval "0"
# APT::Periodic::Unattended-Upgrade "0"

#-----------Install nginx-----------
sudo apt install nginx
nginx --v

#-----------Install Docker-----------

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the key repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

#Install the Docker packages:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt install docker-compose
docker --version
docker-compose --version

#-----------Prepare Docker config file-----------
mkdir service.analyticalman.com # create a new repo
cd service.analyticalman.com 
nano docker-compose.yml #Keep the config for docker-compose.yml here

# Modify and Config the docker-compose.yml file as needed.
# Services of docker-compose.yml includes: a DB(mysql), a wordpress site, and a webserver(local nginx)
# Both Wordpress and the webserver(nginx) services will share the wordpress volume. 
# Change the container names as needed
# Map the port 80 of webserver to something unique. We mapped(changed) it to 8090 here. 
# The target here is that - the webserver will access the wordpress files and serve them to port 8090.

#-----------Prepare .env file (for WP and DB services)-----------
nano .env #Keep the config for .env here
# Modify and Config .env file as needed.

#-----------Prepare nginx.conf file (for local nginx webserver service)-----------
mkdir nginx-conf
cd nginx-conf
nano nginx.conf #Keep the config for nginx.conf here
# Listen to port 80 and serve the wordpress site
# Modify the server_name and Config nginx.conf file as needed.


#-----------Run the docker to build the image-----------
sudo docker compose up -d
sudo docker ps
#-----------Configure the global nginx-----------
# Apply port forwarding so that: 
# When the website service.analyticalman.com is called by (IP Address) - 
#it will read the website name from port 80 (HTTP port) and proxy this is port 8090(local nginx port for the website)

# configure site-available
cd /etc/nginx/sites-available
nano service.analyticalman.com #Keep the config for your site here
# Modify the site-available config (preffered filename is your domain name) as needed
# It mainly says that keep listening from internet (port 80: the HTTP port) and proxy this is port 8090(local nginx port for the website)

# configure site-enabled
cd /etc/nginx/sites-enabled
# create a soft-link between these two files (one in site-available and another site-enabled)
sudo ln -s /etc/nginx/sites-available/service.analyticalman.com .
#or sudo ln -s ../sites-available/service.analyticalman.com .
# return back to site-available
cd /etc/nginx/sites-available

# Reset nginx config and reload the new files
sudo nginx -t  #check if the syntax of current nginx.conf file is ok
sudo systemctl restart nginx #restart nginx


#-----------Install Certbot and secure the site-----------
#https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-22-04
#sudo apt install certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

#certbot --version
sudo certbot --nginx

# Then select the website from the menu and press enter









