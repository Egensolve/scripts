# Read the personal access token from PAT.txt
if [ -f "PAT.txt" ]; then
    PAT_TOKEN=$(cat PAT.txt)
    sudo rm PAT.txt
    echo "${green_color}[SUCCESS] Loaded Personal Access Token from PAT.txt"
else
    echo "${no_color}Error: PAT.txt file not found."
    exit 1
fi

sudo apt-get purge php8.2* libapache2-mod-php8.2 -y

sudo apt-get autoremove --purge -y
sudo apt-get clean -y

sudo apt-get update -y
sudo apt-get install php8.3 php8.3-cli php8.3-fpm php8.3-mysql php8.3-curl php8.3-xml php8.3-mbstring php8.3-zip -y


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
sudo apt remove --purge php8.3-dev -y
sudo apt autoremove
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"RELOADING PHP FPM AND CLI";
CONFIG_DIR="/etc/nginx/sites-available"
for CONFIG_FILE in "$CONFIG_DIR"/*
do
    if [ -f "$CONFIG_FILE" ]; then
        echo "Processing $CONFIG_FILE"
        sed -i 's/php8\.2/php8\.3/g' "$CONFIG_FILE"
        echo "Updated PHP version in $CONFIG_FILE"
    fi
done

PHP_FPM_INI="/etc/php/8.3/fpm/php.ini"
PHP_CLI_INI="/etc/php/8.3/cli/php.ini"

# Function to add the extension line if it doesn't already exist
add_extension_line() {
    local INI_FILE="$1"
    local EXTENSION_LINE="extension=loader.so"

    if ! grep -q "^$EXTENSION_LINE" "$INI_FILE"; then
        echo "$EXTENSION_LINE" >> "$INI_FILE"
        echo "Added $EXTENSION_LINE to $INI_FILE"
    else
        echo "$EXTENSION_LINE already exists in $INI_FILE"
    fi
}

# Add "extension=loader.so" to PHP FPM and CLI ini files
add_extension_line "$PHP_FPM_INI"
add_extension_line "$PHP_CLI_INI"

nginx -s reload

echo "All configurations updated, and Nginx reloaded."

sudo update-alternatives --set php /usr/bin/php8.3
sudo update-alternatives --set phar /usr/bin/phar8.3
sudo update-alternatives --set phar.phar /usr/bin/phar.phar8.3
sudo update-alternatives --set php-config /usr/bin/php-config8.3
sudo update-alternatives --set phpize /usr/bin/phpize8.3
sudo systemctl stop php8.2-fpm
sudo systemctl disable php8.2-fpm
sudo systemctl enable php8.3-fpm
sudo systemctl start php8.3-fpm
sudo systemctl reload php8.3-fpm
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

history -c

# Delete the script file itself
cd
rm -- "$0"
