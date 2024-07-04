#!/bin/bash
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update
apt upgrade -y
apt install -y mysql-server libjsoncpp25 libmariadb3 python3-matplotlib python3-numpy redis libhiredis* jq snapd
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
apt remove -y unattended-upgrades
echo "" >> "/etc/mysql/my.cnf"
echo "[mysqld]" >> "/etc/mysql/my.cnf"
echo "binlog_expire_logs_seconds=1" >> "/etc/mysql/my.cnf"
echo "max_connections=1000" >> "/etc/mysql/my.cnf"
mysql --user="root" --execute="CREATE USER 'comma6a'@'localhost' IDENTIFIED BY 'comma6a';GRANT ALL PRIVILEGES ON *.* TO 'comma6a'@'localhost' WITH GRANT OPTION;"
mysql --user="comma6a" --password="comma6a" --execute="CREATE DATABASE SERVER;"
echo "32181" > porta_server_ws.txt
echo "{\"prima\":32181,\"ultima\":32190}" > porte_server_ws.json

touch script_start.sh
printf "#!/bin/bash
prima=\$(jq '.prima' porte_server_ws.json)
ultima=\$(jq '.ultima' porte_server_ws.json)


for ((i = \$prima; i <= \$ultima; i++))
do
   printf \"[Unit]
Description=SlotServerWS \$i daemon

[Service]
Restart=always
RestartSec=3
User=root
TasksMax=100000
WorkingDirectory=%%s
ExecStart=%%s/ServerWS -p %%i

[Install]
WantedBy=multi-user.target
\" \$HOME \$HOME \$i > /etc/systemd/system/ServerWS\$i.service
done

systemctl daemon-reload 

for ((i = \$prima; i <= \$ultima; i++))
do
systemctl enable ServerWS\$i.service 
systemctl start ServerWS\$i.service
done
" > script_start.sh

chmod +x script_start.sh

touch script_stop.sh

printf "#!/bin/bash
prima=\$(jq '.prima' porte_server_ws.json)
ultima=\$(jq '.ultima' porte_server_ws.json)

for ((i = \$prima; i <= \$ultima; i++))
do
systemctl stop ServerWS\$i.service
systemctl disable ServerWS\$i.service
rm /etc/systemd/system/ServerWS\$i.service
done

systemctl daemon-reload
" > script_stop.sh

chmod +x script_stop.sh

touch script_restart.sh

printf "#!/bin/bash

prima=\$(jq '.prima' porte_server_ws.json)
ultima=\$(jq '.ultima' porte_server_ws.json)

for ((i = \$prima; i <= \$ultima; i++))
do
	systemctl restart ServerWS\$i.service
done
" > script_restart.sh

chmod +x script_restart.sh

touch cambia.sh

printf "#!/bin/bash

# Legge il contenuto attuale del file
current_content=\$(cat /root/porta_server_ws.txt)
prima=\$(jq '.prima' porte_server_ws.json)
ultima=\$(jq '.ultima' porte_server_ws.json)

# Se il contenuto attuale è maggiore di 32190 o vuoto, imposta il nuovo contenuto a 32181; altrimenti, incrementa di uno il contenuto attuale
if [ -z \"\$current_content\" ] || [ \$current_content -ge \$ultima ]; then
  new_content=\$prima
else
  new_content=\$((current_content + 1))
fi

# Scrive il nuovo contenuto nel file
echo \$new_content > /root/porta_server_ws.txt
cat /root/porta_server_ws.txt
" > cambia.sh

chmod +x cambia.sh

touch /etc/systemd/system/ServerHTTP.service


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

certbot certonly --standalone

./script_start.sh

systemctl enable ServerHTTP.service 
systemctl start ServerHTTP.service
systemctl enable redis-server.service
systemctl start redis-server.service

rm -- "$0"