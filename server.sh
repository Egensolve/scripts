#!/bin/sh

script_log_file="script_log.log"
green_color="\033[1;32m"
no_color="\033[0m"
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

branch=""  # No default branch; script will stop if not specified

# Handle the flags
while getopts d:b:-: flag; do
    case "${flag}" in
        d) domain=${OPTARG};;
        b) branch=${OPTARG};;
        -) 
            case "${OPTARG}" in
                domain=*) domain="${OPTARG#*=}";;
                branch=*) branch="${OPTARG#*=}";;
            esac;;
    esac
done

# Check if branch is provided
if [ -z "$branch" ]; then
    echo "${no_color}Error: No branch specified. Use -b or --branch to provide a branch name."
    exit 1
fi

echo $no_color"PREPAIRE INSTALLING";
rm -rf /var/lib/dpkg/lock >> $script_log_file 2>/dev/null
rm -rf /var/lib/dpkg/lock-frontend >> $script_log_file 2>/dev/null
rm -rf /var/cache/apt/archives/lock >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"REMOVING APACHE";
sudo apt-get purge apache -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache* -y >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:80) >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:443) >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING NGINX";
sudo apt-get update   >> $script_log_file 2>/dev/null
sudo apt install nginx -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"OPEN NGINX PORTS";
echo "y" | sudo ufw enable  >> $script_log_file 2>/dev/null
sudo ufw allow 'Nginx HTTP' >> $script_log_file 2>/dev/null
sudo ufw allow 'Nginx HTTPS' >> $script_log_file 2>/dev/null
sudo ufw allow '8443' >> $script_log_file 2>/dev/null
sudo ufw allow OpenSSH  >> $script_log_file 2>/dev/null
sudo add-apt-repository universe -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING PHP 8.2";
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y >> $script_log_file 2>/dev/null
sudo add-apt-repository ppa:ondrej/php -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
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
sudo apt install php8.3-fpm php8.3-redis -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING PHP EXTENSIONS";
# install php 8.2 extensions
sudo apt install redis-server php8.2-redis php8.2 openssl php8.2-fpm php8.2-common php8.2-curl php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip php8.2-gd php8.2-cli php8.2-xml php8.2-imagick php8.2-xml php8.2-intl php-mysql -y >> $script_log_file 2>/dev/null
# install php 8.3 extensions
sudo apt install php8.3 openssl php8.3-fpm php8.3-common php8.3-curl php8.3-mbstring php8.3-mysql php8.3-xml php8.3-zip php8.3-gd php8.3-cli php8.3-xml php8.3-imagick php8.3-xml php8.3-intl php-mysql -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache* -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING NPM";
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.bashrc
nvm install node
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING CERTBOT (SSL GENERATOR)";
sudo apt-get install snap -y  >> $script_log_file 2>/dev/null
sudo apt-get install snapd -y  >> $script_log_file 2>/dev/null
sudo snap install core  >> $script_log_file 2>/dev/null
sudo snap refresh core  >> $script_log_file 2>/dev/null
sudo snap install --classic certbot >> $script_log_file 2>/dev/null
sudo ln -s /snap/bin/certbot /usr/bin/certbot >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING COMPOSER";
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt-get purge composer -y >> $script_log_file 2>/dev/null
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" >> $script_log_file 2>/dev/null
php composer-setup.php >> $script_log_file  2>/dev/null
sudo mv composer.phar /usr/local/bin/composer >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"CREATING NGINX FILE FOR $domain";
sudo rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default >> $script_log_file 2>/dev/null
sudo touch /etc/nginx/sites-available/$domain >> $script_log_file 2>/dev/null
sudo bash -c "echo 'server {
    listen 80;
    listen [::]:80;
    root /var/www/'$branch'/public;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name '$domain';
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    location ~ /\.ht {
            deny all;
    }
}' > /etc/nginx/sites-available/$domain" >> $script_log_file 2>/dev/null
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/ >> $script_log_file 2>/dev/null
sudo mkdir /var/www/$branch >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";




echo $no_color"GENERATING SSL CERTIFICATE FOR $domain"
certbot --nginx -d $domain --non-interactive --agree-tos -m admin@$domain >> $script_log_file 2>/dev/null
rm -rf /etc/nginx/sites-available/$domain >> $script_log_file 2>/dev/null
sudo touch /etc/nginx/sites-available/$domain >> $script_log_file 2>/dev/null

sudo bash -c "echo 'server {
    listen 80;
    #access_log off;
    root /var/www/'$branch'/public;
    index index.php index.html index.htm index.nginx-debian.html;
    client_max_body_size 1000M;
    fastcgi_read_timeout 8600;
    proxy_cache_valid 200 365d;
    if (!-d \$request_filename) {
      rewrite ^/(.+)/$ /\$1 permanent;
    }
    if (\$request_uri ~* "\/\/") {
      rewrite ^/(.*) /\$1 permanent;
    }
    location ~ \.(env|log|htaccess)\$ {
        deny all;
    }
    location ~*\.(?:js|jpg|jpeg|gif|png|css|tgz|gz|rar|bz2|doc|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|woff|woff2|svg|mp3|jpe?g,eot|ttf|svg)\$ {
        access_log off;
        expires 360d;
        add_header Access-Control-Allow-Origin *;
        add_header Pragma public;
        add_header Cache-Control \"public\";
        add_header Vary Accept-Encoding; 
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location / {
        add_header Access-Control-Allow-Origin *;
        if (\$request_uri ~* \"^(.*/)index\.php(/?)(.*)\") {
              return 301 \$1\$3;
        }
        if (\$host ~* ^(www)) {
            rewrite ^/(.*)\$ https://'$domain'/\$1 permanent;
        }
        if (\$scheme = http) {
            return 301 https://'$domain'\$request_uri;
        }
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
   listen 443 ssl; # managed by Certbot
   server_name '$domain';
   ssl_certificate /etc/letsencrypt/live/'$domain'/fullchain.pem; # managed by Certbot
   ssl_certificate_key /etc/letsencrypt/live/'$domain'/privkey.pem; # managed by Certbot
   include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
   ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}' > /etc/nginx/sites-available/$domain" >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

if ! [ -x "$(command -v mysql)"  >> $script_log_file 2>/dev/null ]; then
echo $no_color"INSTALLING MYSQL";
export DEBIAN_FRONTEND=noninteractive
echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
sudo apt-get -qq install mysql-server  >> $script_log_file 2>/dev/null

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
sudo bash -c "echo $MYSQL_ROOT_PASSWORD > /var/www/html/mysql"  >> $script_log_file 2>/dev/null
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


if ! [ -x "$(command -v mysql)"  >> $script_log_file 2>/dev/null ]; then
echo $green_color"[MYSQL ALREADY INSTALLED!]";
echo $green_color"[######################################]";
fi

echo $no_color"PUSHING CRONJOBS";
(crontab -l 2>/dev/null; echo "################## START $domain ####################") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/$branch && php artisan schedule:run >> /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "################## END $domain ####################") | crontab -
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"FINALIZE INSTALLING";
sudo apt-get autoremove -y >> $script_log_file 2>/dev/null
sudo bash -c "echo 'net.core.netdev_max_backlog = 65535'" | sudo tee -a /etc/sysctl.conf >> $script_log_file 2>/dev/null
sudo bash -c "echo 'net.core.somaxconn = 65535'" | sudo tee -a /etc/sysctl.conf >> $script_log_file 2>/dev/null
sudo apt-get autoclean -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


# Read the personal access token from PAT.txt
if [ -f "PAT.txt" ]; then
    PAT_TOKEN=$(cat PAT.txt)
    sudo rm PAT.txt
    echo "${green_color}[SUCCESS] Loaded Personal Access Token from PAT.txt"
else
    echo "${no_color}Error: PAT.txt file not found."
    exit 1
fi


echo $green_color"CLONING REPOSITORY";
mkdir -p /var/www/$branch
cd /var/www/$branch || { echo "${no_color}Error: Failed to change directory to /var/www/$branch"; exit 1; }
git init
git remote add origin https://$PAT_TOKEN@github.com/Egensolve/system_clients.git
git pull origin $branch
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to clone the repository."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"RUNNING COMPOSER";
composer update -n
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to run composer update."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $green_color"UPDATING .ENV";
cp .env.example .env
sed -i "s|APP_URL=http://127.0.0.1:8000|APP_URL=https://$domain|g" .env
sed -i "s|DB_DATABASE=lms|DB_DATABASE=$branch|g" .env
sed -i "s|DB_PASSWORD=|DB_PASSWORD=$MYSQL_ROOT_PASSWORD|g" .env
sed -i "s|WHATSAPP_SERVER_URL=|WHATSAPP_SERVER_URL=https://$domain:3000|g" .env
sed -i "s|CHAT_SERVER_URL=|CHAT_SERVER_URL=https://$domain:5000|g" .env
php artisan key:generate
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to update .env or generate app key."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $green_color"INSTALLING SYSTEM THEME";
apt-get install -y unzip
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to install unzip."
    exit 1
fi


mv system_theme-main.zip storage/app
cd storage/app || { echo "${no_color}Error: Failed to change directory to storage/app"; exit 1; }
unzip system_theme-main.zip
mv system_theme-main public
cd ../..
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to install the system theme."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $green_color"LINKING STORAGE";
php artisan storage:link
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to create storage link."
    exit 1
fi
chmod -R 777 storage
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to set permissions on storage."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


# Create the database
echo $green_color"CREATING DATABASE";
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $branch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to create the database."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


# Source SQL file into the database
echo $green_color"SOURCING SQL FILE";
mysql -u root -p$MYSQL_ROOT_PASSWORD $branch < countries_cities_timezone_currency.sql
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to source the SQL file."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


# Run Laravel migrations
echo $green_color"RUNNING MIGRATIONS";
php artisan migrate --seed -force
if [ $? -ne 0 ]; then
    echo "${no_color}Error: Failed to run migrations."
    exit 1
fi
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"STARTING DECRYPTOR INSTALLATION";
sudo apt update -y
sudo apt upgrade -y
sudo apt install php8.3-dev -y
sudo apt install libcrypto++-dev -y
sudo apt install g++ -y
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"CLONING DECRYPTOR";
git clone https://$PAT_TOKEN@github.com/OmarYacop/php_decryptor.git
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"INSTALLING DECRYPTOR";
cd php_decryptor
phpize
./configure
sed -i '/^CPPFLAGS =/a CPPFLAGS += -I/usr/include/cryptopp' Makefile
sed -i 's|^LDFLAGS =.*|LDFLAGS = -L/usr/lib/x86_64-linux-gnu -lcryptopp|' Makefile
make
sudo make install
cd ..
sudo rm -r php_decryptor
sudo apt remove --purge php8.2-dev
sudo apt autoremove
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"RELOADING PHP FPM AND CLI";
sudo sed -i '/^;zlib.output_handler =/a extension=loader.so' /etc/php/8.2/cli/php.ini
sudo sed -i '/^;zlib.output_handler =/a extension=loader.so' /etc/php/8.2/fpm/php.ini
sudo sed -i '/^;zlib.output_handler =/a extension=loader.so' /etc/php/8.3/cli/php.ini
sudo sed -i '/^;zlib.output_handler =/a extension=loader.so' /etc/php/8.3/fpm/php.ini
sudo systemctl reload php8.2-fpm
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING WHATSAPP";
sudo apt-get install -y chromium-browser && sudo apt-get install ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils
mkdir /var/www/"${branch}_whatsapp"
cd /var/www/"${branch}_whatsapp"
git clone https://$PAT_TOKEN@github.com/SayedAbbady/whatsapp-server.git
mv whatsapp-server mtz_wwebjs
cd mtz_wwebjs
npm i
npm i pm2 -g
sed -i "s|const DomainName = \"127.0.0.1\";|const DomainName = \"${domain}\";|" src/server.js
cd ..
echo "require('./mtz_wwebjs/src/server.js');" > "${branch}".js
pm2 start "${branch}".js
pm2 startup
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"INSTALLING SUPERVISOR";
sudo apt-get install -y supervisor
sudo bash -c 'cat > /etc/supervisor/conf.d/"${branch}_laravel-worker.conf" <<EOL
[program:${branch}_laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/${branch}/artisan queue:work --queue=veryhigh,high,low,default --sleep=3 --tries=3
autostart=true
autorestart=true
user=root
numprocs=8
redirect_stderr=true
stdout_logfile=/var/www/${branch}/storage/logs/worker.log
EOL'
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start "${branch}_laravel-worker:*"
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

unset PAT_TOKEN;
unset MYSQL_ROOT_PASSWORD;
unset branch;

echo $green_color"[MADE WITH LOVE BY OK]";
echo $green_color"[####################]";
