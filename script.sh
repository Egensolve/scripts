#!/bin/sh

script_log_file="script_log.log"
green_color="\033[1;32m"
no_color="\033[0m"
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done

echo $no_color"PREPARING INSTALLATION";
rm -rf /var/lib/dpkg/lock >> $script_log_file 2>/dev/null
rm -rf /var/lib/dpkg/lock-frontend >> $script_log_file 2>/dev/null
rm -rf /var/cache/apt/archives/lock >> $script_log_file 2>/dev/null
sudo apt-get update >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"REMOVING NGINX";
sudo apt-get purge nginx -y >> $script_log_file 2>/dev/null
sudo apt-get purge nginx* -y >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:80) >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:443) >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING APACHE";
sudo apt-get update >> $script_log_file 2>/dev/null
sudo apt install apache2 -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"OPENING APACHE PORTS";
echo "y" | sudo ufw enable >> $script_log_file 2>/dev/null
sudo ufw allow 'Apache' >> $script_log_file 2>/dev/null
sudo ufw allow 'Apache Full' >> $script_log_file 2>/dev/null
sudo ufw allow OpenSSH >> $script_log_file 2>/dev/null
sudo add-apt-repository universe -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING APACHE";
sudo systemctl start apache2 >> $script_log_file 2>/dev/null
sudo service apache2 restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING PHP 8.2";
sudo apt-get update >> $script_log_file 2>/dev/null
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y >> $script_log_file 2>/dev/null
sudo add-apt-repository ppa:ondrej/php -y >> $script_log_file 2>/dev/null
sudo apt-get update >> $script_log_file 2>/dev/null
sudo apt install php8.2 -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

# install php 8.2 fpm
echo $no_color"INSTALLING PHP 8.2 FPM";
sudo apt install php8.2-fpm -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";
echo $no_color"INSTALLING PHP 8.2 COMMON";
sudo apt install php8.2-common -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

#install php 8.3
echo $no_color"INSTALLING PHP 8.3";
sudo apt install php8.3 -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

# install php 8.3 fpm
echo $no_color"INSTALLING PHP 8.3 FPM";
sudo apt install php8.3-fpm -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING PHP EXTENSIONS";
# install php 8.2 extensions
sudo apt install php8.2 openssl php8.2-fpm php8.2-common php8.2-curl php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip php8.2-gd php8.2-cli php8.2-xml php8.2-imagick php8.2-xml php8.2-intl php-mysql -y >> $script_log_file 2>/dev/null
# install php 8.3 extensions
sudo apt install php8.3 openssl php8.3-fpm php8.3-common php8.3-curl php8.3-mbstring php8.3-mysql php8.3-xml php8.3-zip php8.3-gd php8.3-cli php8.3-xml php8.3-imagick php8.3-xml php8.3-intl php-mysql -y >> $script_log_file 2>/dev/null
sudo apt-get purge nginx -y >> $script_log_file 2>/dev/null
sudo apt-get purge nginx* -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING NPM";
sudo apt install npm -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING CERTBOT (SSL GENERATOR)";
sudo apt-get install snap -y >> $script_log_file 2>/dev/null
sudo apt-get install snapd -y >> $script_log_file 2>/dev/null
sudo snap install core >> $script_log_file 2>/dev/null
sudo snap refresh core >> $script_log_file 2>/dev/null
sudo snap install --classic certbot >> $script_log_file 2>/dev/null
sudo ln -s /snap/bin/certbot /usr/bin/certbot >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $green_color"[######################################]";
echo $no_color"INSTALLING COMPOSER";
sudo apt-get update >> $script_log_file 2>/dev/null
sudo apt-get purge composer -y >> $script_log_file 2>/dev/null
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" >> $script_log_file 2>/dev/null
php composer-setup.php >> $script_log_file 2>/dev/null
sudo mv composer.phar /usr/local/bin/composer >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING APACHE";
sudo systemctl start apache2 >> $script_log_file 2>/dev/null
sudo service apache2 restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"CREATING APACHE CONFIG FILE FOR $domain";
sudo rm -rf /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf >> $script_log_file 2>/dev/null
sudo touch /etc/apache2/sites-available/$domain.conf >> $script_log_file 2>/dev/null
sudo bash -c "echo '<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/html/$domain/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/html/$domain/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>' > /etc/apache2/sites-available/$domain.conf" >> $script_log_file 2>/dev/null
sudo a2ensite $domain.conf >> $script_log_file 2>/dev/null
sudo systemctl reload apache2 >> $script_log_file 2>/dev/null
sudo mkdir /var/www/html/$domain >> $script_log_file 2>/dev/null
sudo mkdir /var/www/html/$domain/public >> $script_log_file 2>/dev/null
sudo bash -c "echo  '<h1 style=\"color:#0194fe\">Welcome</h1><h4 style=\"color:#0194fe\">$domain</h4>' > /var/www/html/$domain/public/index.php" >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING APACHE";
sudo systemctl start apache2 >> $script_log_file 2>/dev/null
sudo service apache2 restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"GENERATING SSL CERTIFICATE FOR $domain"
certbot --apache -d $domain -d www.$domain --non-interactive --agree-tos -m admin@$domain >> $script_log_file 2>/dev/null
sudo touch /etc/apache2/sites-available/$domain.conf >> $script_log_file 2>/dev/null

sudo bash -c "echo '<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/html/$domain/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/html/$domain/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =$domain [OR]
    RewriteCond %{SERVER_NAME} =www.$domain
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/html/$domain/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/html/$domain/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$domain/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>' > /etc/apache2/sites-available/$domain.conf" >> $script_log_file 2>/dev/null
sudo systemctl reload apache2 >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING APACHE";
sudo service apache2 restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

if ! [ -x "$(command -v mysql)" >> $script_log_file 2>/dev/null ]; then
echo $no_color"INSTALLING MYSQL";
export DEBIAN_FRONTEND=noninteractive
echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
sudo apt-get -qq install mysql-server >> $script_log_file 2>/dev/null

sudo apt-get -qq install expect >> $script_log_file 2>/dev/null
tee ~/secure_our_mysql.sh << EOF >> $script_log_file 2>/dev/null 
spawn $(which mysql_secure_installation)

expect "Enter password for user root:"
send "$MYSQL_ROOT_PASSWORD\r"
expect "Press y|Y for Yes, any other key for No:"
send "y\r"
expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "0\r"
expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"
expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "n\r"
expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"
EOF
sudo expect ~/secure_our_mysql.sh >> $script_log_file 2>/dev/null
rm -v ~/secure_our_mysql.sh >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS] YOUR ROOT PASSWORD IS : $MYSQL_ROOT_PASSWORD"; >> $script_log_file 2>/dev/null
sudo bash -c "echo $MYSQL_ROOT_PASSWORD > /var/www/html/mysql" >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";
fi

echo $green_color"CHANGING PHP FPM UPLOAD VALUES";
sudo sed -i 's/post_max_size = 8M/post_max_size = 1000M/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1000M/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/memory_limit = 128/memory_limit = 12800/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo service php8.2-fpm restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

if ! [ -x "$(command -v mysql)" >> $script_log_file 2>/dev/null ]; then
echo $green_color"[MYSQL ALREADY INSTALLED!]";
echo $green_color"[######################################]";
fi

echo $no_color"PUSHING CRONJOBS";
(crontab -l 2>/dev/null; echo "################## START $domain ####################") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && rm -rf ./.git/index.lock && rm -rf ./.git/index && git reset --hard HEAD && git clean -f -d && git pull origin master --allow-unrelated-histories") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && php artisan queue:restart && php artisan queue:work >> /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && php artisan schedule:run >> /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && chmod -R 777 *") | crontab -
(crontab -l 2>/dev/null; echo "################## END $domain ####################") | crontab -
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"FINALIZING INSTALLATION";
sudo apt-get autoremove -y >> $script_log_file 2>/dev/null
sudo bash -c "echo 'net.core.netdev_max_backlog = 65535'" | sudo tee -a /etc/sysctl.conf >> $script_log_file 2>/dev/null
sudo bash -c "echo 'net.core.somaxconn = 65535'" | sudo tee -a /etc/sysctl.conf >> $script_log_file 2>/dev/null
sudo apt-get autoclean -y >> $script_log_file 2>/dev/null
sudo apt-get update >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $green_color"[MADE WITH LOVE BY Peter Ayoub PeterAyoub.me]";
echo $green_color"[####################]";
