# Read the personal access token from PAT.txt
if [ -f "PAT.txt" ]; then
    PAT_TOKEN=$(cat PAT.txt)
    sudo rm PAT.txt
    echo "${green_color}[SUCCESS] Loaded Personal Access Token from PAT.txt"
else
    echo "${no_color}Error: PAT.txt file not found."
    exit 1
fi

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
