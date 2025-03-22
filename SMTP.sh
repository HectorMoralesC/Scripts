#!/bin/bash

# Variables
DOMAIN="tu_nom.lab"
NETWORK="10.XXX.30.0/24"
MYSQL_ROOT_PASSWORD="password"
ROUNDCUBE_DB_PASSWORD="roundcubepass"

# Actualizar el sistema
echo "Actualizando el sistema..."
apt-get update && apt-get upgrade -y

# Instalar Postfix, Dovecot, y dependencias
echo "Instalando Postfix, Dovecot, y dependencias..."
apt-get install -y postfix dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql mysql-server apache2 php libapache2-mod-php php-mysql

# Configurar Postfix
echo "Configurando Postfix..."
postconf -e "myhostname = mail.$DOMAIN"
postconf -e "mydomain = $DOMAIN"
postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"
postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $NETWORK"
postconf -e "home_mailbox = Maildir/"

# Configurar Dovecot
echo "Configurando Dovecot..."
echo "protocols = imap lmtp" >> /etc/dovecot/dovecot.conf
echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/conf.d/10-mail.conf
echo "disable_plaintext_auth = no" >> /etc/dovecot/conf.d/10-auth.conf
echo "auth_mechanisms = plain login" >> /etc/dovecot/conf.d/10-auth.conf

# Reiniciar servicios
echo "Reiniciando servicios..."
systemctl restart postfix
systemctl restart dovecot

# Instalar Roundcube
echo "Instalando Roundcube..."
apt-get install -y roundcube roundcube-core roundcube-mysql roundcube-plugins

# Configurar Roundcube
echo "Configurando Roundcube..."
echo "Alias /webmail /var/lib/roundcube" >> /etc/apache2/sites-available/000-default.conf
systemctl restart apache2

# Crear base de datos para Roundcube
echo "Creando base de datos para Roundcube..."
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE roundcubedb;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '$ROUNDCUBE_DB_PASSWORD';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON roundcubedb.* TO 'roundcube'@'localhost';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# Configurar Roundcube para usar la base de datos
echo "Configurando Roundcube para usar la base de datos..."
cp /etc/roundcube/debian-db.php /etc/roundcube/config.inc.php
sed -i "s/roundcubedb/roundcubedb/g" /etc/roundcube/config.inc.php
sed -i "s/roundcube/roundcube/g" /etc/roundcube/config.inc.php
sed -i "s/password/$ROUNDCUBE_DB_PASSWORD/g" /etc/roundcube/config.inc.php

# Reiniciar Apache
echo "Reiniciando Apache..."
systemctl restart apache2

echo "Instalación y configuración completada."
echo "Accede a Roundcube en http://tu_ip/webmail"