# Домашнее задание "Система мониторинга Zabbix". Ярмощук Павел

## Задание 1: Установите Zabbix Server с веб-интерфейсом.

**Решение 1:**

## Использованные команды (на VM1 - Zabbix Server, Zabbix Agent)
apt install postgresql -y

sudo -s

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update

apt install zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix

zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

### Скрины к заданию 1
![авторизация](img/снимок-1.png)

## Задание 2: Установите Zabbix Agent на два хоста.

**Решение 2:**

## Использованные команды (на VM2: Zabbix Agent)
sudo -s

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update

apt install zabbix-agent

nano /etc/zabbix/zabbix_agentd.conf
*Server=10.130.0.10*
*ServerActive=10.130.0.10*

systemctl restart zabbix-agent
systemctl enable zabbix-agent

### Скрины к заданию 2
![хосты](img/снимок-2.png)
![логи](img/снимок-3.png)
![ЛД ВМ1](img/снимок-4.png)
![ЛД ВМ2](img/снимок-5.png)