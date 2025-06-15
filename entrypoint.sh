# 启动 nginx
nginx

# 启动 php-fpm
if test $1 == 74 ; then
  /opt/remi/php74/root/sbin/php-fpm -R
fi

if test $1 == 80 ; then
  /opt/remi/php80/root/sbin/php-fpm -R
fi

# 启动 redis
redis-server /etc/redis/redis.conf
