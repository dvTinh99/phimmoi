#!/bin/bash
# sudo DEBIAN_FRONTEND="noninteractive"  # Set non-interactive mode
# # Update Package List
# sudo apt update

# # Upgrade Packages
# sudo apt upgrade -yq
export DEBIAN_FRONTEND=noninteractive
apt -yq update

export DEBIAN_FRONTEND=noninteractive
apt -yq upgrade


# Install Nginx
sudo apt install nginx -y

# Start and enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Add ppa:ondrej/php which has PHP 8.2 package
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.2 and some common extensions
sudo apt install jq php8.2-zip php8.2 php8.2-fpm php8.2-mysql php8.2-cli php8.2-curl php8.2-xml php8.2-mbstring -y

# Start and enable php8.2-fpm service
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm

# Download and install Composer globally
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

# Install MySQL Server
# Install MySQL
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt install mysql-server -y


# Set Root Password for MySQL (Alternative way)
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
# sudo mysql -e "FLUSH PRIVILEGES;"
mysql -uroot -p'root' -e "CREATE DATABASE IF NOT EXISTS phimmoi;" 
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '@admiN123';"
# sudo mysql -uroot -p -e "FLUSH PRIVILEGES;"
# Output versions
echo "Nginx version:"
nginx -v

echo "PHP version:"
php -v

echo "MySQL version:"
mysql --version

chmod +x clone.sh
sudo ./clone.sh

cp example.conf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

systemctl restart nginx

cd example

#edit env
rm .env
tee .env <<EOF
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:HH8ea05PFCs0Pm7/Pas4Q7CpDaFUCIIf9Hw5KN0TzKI=
APP_DEBUG=true
APP_URL=https://netphim.site

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=phimmoi
DB_USERNAME=root
DB_PASSWORD=root

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=null
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

EOF

export COMPOSER_ALLOW_SUPERUSER=1
composer install
# expect "Continue as root/super user"
# send "y \r"
# composer require hacoidev/ophim-core -W


php artisan ophim:install
php artisan ophim:user
php artisan ophim:menu:generate
# mysql -e "use phimmoi; INSERT INTO users (name, email, password) values ('admin', 'admin@gmail.com', '$2y$10$gc5x77/BXeND.NQDEXPeHOju8IgXxU30qBTokkd1ELXGjss9TNAoy')" -p

chmod -R 777 /var/www/example/storage/
chmod -R 777 /var/www/example/public/

composer require hacoidev/ophim-crawler
composer require hacoidev/ophim-ripple

cp CoreProvider.php /var/www/example/vendor/hacoidev/ophim-core/src/OphimServiceProvider.php