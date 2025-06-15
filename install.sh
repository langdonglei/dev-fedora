set -ex

# ssh
dnf install -y openssh-server
/usr/bin/ssh-keygen -A
echo 'root:root' | chpasswd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# nginx
dnf install -y nginx
cat > /etc/nginx/nginx.conf << 'EOF'
user root;
worker_processes auto;
pcre_jit on;
error_log /var/log/nginx/error.log warn;
include /etc/nginx/modules/*.conf;
events {
	worker_connections 1024;
}
http {
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	server_tokens off;
	client_max_body_size 111m;
	sendfile on;
	tcp_nopush on;
	ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	ssl_session_cache shared:SSL:2m;
	ssl_session_timeout 1h;
	ssl_session_tickets off;
	gzip_vary on;
	map $http_upgrade $connection_upgrade {
		default upgrade;
		'' close;
	}
	log_format main '$remote_addr - $remote_user [$time_local] "$request" '
			'$status $body_bytes_sent "$http_referer" '
			'"$http_user_agent" "$http_x_forwarded_for"';
	access_log /var/log/nginx/access.log main;
    server {
        server_name dev;
        root /www/public;
        index index.html index.php;
        location / {
            if (!-e $request_filename) {
                rewrite ^(.*)$ /index.php?s=$1 last;
            }
        }
        location ~ \.php {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        }
    }
}
EOF

# redis
dnf install -y redis
echo 'bind * -::*' >> /etc/redis/redis.conf
echo 'protected-mode no' >> /etc/redis/redis.conf

# php
dnf install -y https://rpms.remirepo.net/fedora/remi-release-40.rpm
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
