#!/bin/bash
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update
apt upgrade -y
apt install -y mysql-server libjsoncpp25 libmariadb3 python3-matplotlib python3-numpy redis libhiredis*
apt remove unattended-upgrades
echo "" >> "/etc/mysql/my.cnf"
echo "[mysqld]" >> "/etc/mysql/my.cnf"
echo "binlog_expire_logs_seconds=1" >> "/etc/mysql/my.cnf"
mysql --user="root" --execute="CREATE USER 'comma6a'@'localhost' IDENTIFIED BY 'comma6a';GRANT ALL PRIVILEGES ON *.* TO 'comma6a'@'localhost' WITH GRANT OPTION;"
#mysql --user="comma6a" --password="comma6a" --execute="CREATE DATABASE SERVER;"

home_path=$HOME
for i in {32181..32190}
do
printf "[Unit]
Description=SlotServerWS $i daemon

[Service]
Restart=always
RestartSec=3
User=root
TasksMax=100000
WorkingDirectory=%s
ExecStart=%s/ServerWS -p %i

[Install]
WantedBy=multi-user.target
" $HOME $HOME $i > /etc/systemd/system/ServerWS$i.service
done

printf "[Unit]
Description=SlotServer daemon

[Service]
Restart=always
RestartSec=3
User=root
TasksMax=100000
WorkingDirectory=%s
ExecStart=%s/ServerHTTP

[Install]
WantedBy=multi-user.target
" $HOME $HOME > /etc/systemd/system/ServerHTTP.service

systemctl daemon-reload 
systemctl enable ServerHTTP.service 
systemctl start ServerHTTP.service
for i in {32181..32190}
do
systemctl enable ServerWS$i.service 
systemctl start ServerWS$i.service
done
systemctl enable redis-server.service
systemctl start redis-server.service

rm -- "$0"