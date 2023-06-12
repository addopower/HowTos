apt update
apt upgrade -y
apt install -y mysql-server libjsoncpp25 libmariadb3 python3-matplotlib python3-numpy
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

rm -- "$0"