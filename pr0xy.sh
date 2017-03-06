#!/bin/bash
echo 'ANTI-ABUSER9000 yoba script by cr33p'
apt-get update
apt-get upgrade -y
apt-get install mc iptraf nano -y
apt-get autoremove accountsservice lxd snapd nginx -y
wget -O /tmp/nginx_signing.key http://nginx.org/keys/nginx_signing.key
apt-key add /tmp/nginx_signing.key
echo "deb http://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" | sudo tee -a /etc/apt/sources.list.d/nginx.list
apt-get update
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
apt-get install nginx -y
sed -i 's#http {#http {\nproxy_max_temp_file_size 0;\nproxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=my_cache:64m inactive=30d max_size=10g;#g' /etc/nginx/nginx.conf
sed -i 's/worker_processes  1;/worker_processes  auto;\nworker_rlimit_nofile 3000;/g' /etc/nginx/nginx.conf
sed -i 's#access_log  /var/log/nginx/access.log  main;#access_log off;#g' /etc/nginx/nginx.conf
sed -i 's#error_log  /var/log/nginx/error.log warn;#error_log off;#g' /etc/nginx/nginx.conf
cat >/etc/nginx/conf.d/proxy.conf <<EOL
server {
  listen 80;
  server_name $2;
  location / {
    proxy_pass_header Server;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://$1;
  }
  location ~* ^.+\.(jpg|jpeg|gif|png|svg|js|css|mp3|ogg|mpe?g|avi|zip|gz|bz2?|rar|swf)$ {
    proxy_pass_header Server;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://$1;
    proxy_cache my_cache;
  }
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }
}
EOL
service nginx restart