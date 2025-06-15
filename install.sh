set -ex

# ssh
dnf install -y openssh-server sshpass passwd
/usr/bin/ssh-keygen -A
echo root:root | chpasswd
sed -i 's|GSSAPIAuthentication yes|GSSAPIAuthentication no|' /etc/ssh/sshd_config
sed -i 's|#UseDNS yes|UseDNS no|' /etc/ssh/sshd_config
sed -i 's|#PermitRootLogin yes|PermitRootLogin yes|' /etc/ssh/sshd_config

# nginx
dnf install -y nginx
#sed -i 's|root /www|root /www/public|' /etc/nginx/conf.d/default.conf
#sed -i 's|user  nginx|user  root|'     /etc/nginx/nginx.conf

# redis
dnf install -y redis
#sed -i 's|bind 127.0.0.1|bind 0.0.0.0|g' /etc/redis.conf
#sed -i 's|protected-mode yes|protected-mode no|g' /etc/redis.conf

# php
dnf install -y https://rpms.remirepo.net/fedora/remi-release-42.rpm
for i in 73 74 80
do
    dnf install -y \
        php${i}-php-cli \
        php${i}-php-fpm \
        php${i}-php-xml \
        php${i}-php-mbstring \
        php${i}-php-pgsql \
        php${i}-php-zip \
        php${i}-php-redis \
        php${i}-php-bcmath \
        php${i}-php-gd \
        php${i}-php-swoole \
        php${i}-php-process \
        php${i}-php-sodium \
        php${i}-php-sqlsrv \
        php${i}-php-pecl-xdebug3
    cat >> /etc/opt/remi/php${i}/php.ini << EOF
    error_reporting=E_ALL
    display_errors=1
    date.timezone=PRC
    zend.assertions=1
EOF
    cat >> /etc/opt/remi/php${i}/php.d/15-xdebug.ini << EOF
    xdebug.mode=debug
    xdebug.client_host=host.docker.internal
    xdebug.log=/tpm/xdebug.log
EOF
    sed -i 's|apache|root|g'                                            /etc/opt/remi/php${i}/php-fpm.d/www.conf
done
