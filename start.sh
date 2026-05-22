#!/bin/bash
set -e
echo "=== 安装系统依赖 ==="
apt-get update -y
apt-get install -y git unzip curl zip libpq-dev zlib1g-dev libpng-dev
echo "=== 安装 PHP 扩展 ==="
docker-php-ext-install pdo_pgsql gd mbstring exif pcntl bcmath
echo "=== 安装 Composer ==="
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
echo "=== 克隆代码 ==="
rm -rf /var/www/html/*
git clone https://github.com/yaojingang/GEOFlow.git /tmp/geoflow
cp -r /tmp/geoflow/. /var/www/html/
cd /var/www/html
echo "=== 配置环境变量 ==="
cp .env.example .env
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=geoflow-postgresql.ns-q8q5y2y4.svc/g' .env
sed -i 's/DB_DATABASE=geo_flow/DB_DATABASE=geoflow/g' .env
sed -i 's/DB_USERNAME=geo_user/DB_USERNAME=geoflow/g' .env
sed -i 's/DB_PASSWORD=geo_password/DB_PASSWORD=q42w79lj/g' .env
sed -i 's/REDIS_HOST=redis/REDIS_HOST=est-db-redis-redis.ns-q8q5y2y4.svc/g' .env
sed -i 's/REDIS_PASSWORD=null/REDIS_PASSWORD=4701ziNu0z/g' .env
sed -i 's/GEOFLOW_ADMIN_PASSWORD=password/GEOFLOW_ADMIN_PASSWORD=GeoFlow@2026/g' .env
sed -i 's|APP_URL=http://localhost:18080|APP_URL=http://localhost:8080|g' .env
sed -i 's/APP_PORT=18080/APP_PORT=8080/g' .env
echo "=== 安装依赖 ==="
composer install --no-interaction
echo "=== 初始化 Laravel ==="
php artisan key:generate --force
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
echo "=== 启动服务 ==="
php artisan serve --host=0.0.0.0 --port=8080
