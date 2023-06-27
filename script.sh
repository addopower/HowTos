curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update
apt upgrade -y
apt install -y mysql-server libjsoncpp25 libmariadb3 python3-matplotlib python3-numpy redis libhiredis*
mysql --user="root" --execute="CREATE USER 'comma6a'@'localhost' IDENTIFIED BY 'comma6a';GRANT ALL PRIVILEGES ON *.* TO 'comma6a'@'localhost' WITH GRANT OPTION;"
mysql --user="comma6a" --password="comma6a" --execute="CREATE DATABASE SERVER;"
printf "[Unit]
Description=SlotServer daemon

[Service]
Restart=always
RestartSec=3
User=root
TasksMax=100000
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/ServerWSPrimario

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/ServerWSPrimario.service

printf "[Unit]
Description=SlotServer daemon

[Service]
Restart=always
RestartSec=3
User=root
TasksMax=100000
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/ServerHTTP

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/ServerHTTP.service

systemctl daemon-reload 
systemctl enable ServerHTTP.service 
systemctl start ServerHTTP.service
systemctl enable ServerWSPrimario.service 
systemctl start ServerWSPrimario.service
systemctl enable redis-server.service
systemctl start redis-server.service

rm -- "$0"