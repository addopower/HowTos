apt update
apt install -y mysql-server
mysql --user="root" --execute="CREATE USER 'comma6a'@'localhost' IDENTIFIED BY 'comma6a';GRANT ALL PRIVILEGES ON *.* TO 'comma6a'@'localhost' WITH GRANT OPTION;"
mysql --user="comma6a" --password="comma6a" --execute="CREATE DATABASE NOME_DB;"
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
WantedBy=multi-user.target" > /etc/systemd/system/ServerWSPrimario.service

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
WantedBy=multi-user.target" > /etc/systemd/system/ServerHTTP.service

systemctl daemon-reload 
systemctl enable ServerHTTP.service 
systemctl start ServerHTTP.service
systemctl enable ServerWSPrimario.service 
systemctl start ServerWSPrimario.service

rm -- "$0"