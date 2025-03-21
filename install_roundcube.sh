#!/bin/bash

# Variables
DOMAIN="nfs.hector.lab"  # Cambia esto por tu dominio
MYSQL_ROOT_PASSWORD="password"  # Cambia esto por la contraseña de root de MySQL
ROUNDCUBE_DB_USER="roundcube"
ROUNDCUBE_DB_PASSWORD="Sk3ijDA1w35G"  # Cambia esto si es necesario
ROUNDCUBE_DB_NAME="roundcube"

# Actualizar el sistema
echo "Actualizando el sistema..."
apt-get update && apt-get upgrade -y

# Instalar paquetes necesarios
echo "Instalando Apache, MariaDB, Roundcube, Postfix y Dovecot..."
apt-get install -y apache2 mariadb-server mariadb-client php libapache2-mod-php php-mysql \
    roundcube roundcube-core roundcube-mysql roundcube-plugins \
    postfix dovecot-core dovecot-imapd dovecot-lmtpd

# Configurar MySQL/MariaDB
echo "Configurando MySQL/MariaDB..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE $ROUNDCUBE_DB_NAME;
CREATE USER '$ROUNDCUBE_DB_USER'@'localhost' IDENTIFIED BY '$ROUNDCUBE_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $ROUNDCUBE_DB_NAME.* TO '$ROUNDCUBE_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Importar el esquema de Roundcube
echo "Importando el esquema de Roundcube..."
mysql -u "$ROUNDCUBE_DB_USER" -p"$ROUNDCUBE_DB_PASSWORD" "$ROUNDCUBE_DB_NAME" < /usr/share/roundcube/SQL/mysql.initial.sql

# Configurar Roundcube
echo "Configurando Roundcube..."
cp /etc/roundcube/debian-db.php /etc/roundcube/config.inc.php

# Añadir la línea de configuración de la base de datos
echo "Añadiendo configuración de la base de datos a Roundcube..."
tee -a /etc/roundcube/config.inc.php > /dev/null <<EOF
\$config['db_dsnw'] = 'mysql://$ROUNDCUBE_DB_USER:$ROUNDCUBE_DB_PASSWORD@localhost/$ROUNDCUBE_DB_NAME';
EOF

# Configurar Apache para Roundcube
echo "Configurando Apache para Roundcube..."
tee /etc/apache2/sites-available/000-default.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    Alias /webmail /var/lib/roundcube
    <Directory /var/lib/roundcube>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Habilitar módulos de Apache
echo "Habilitando módulos de Apache..."
a2enmod alias
systemctl restart apache2

# Configurar permisos de Roundcube
echo "Configurando permisos de Roundcube..."
chmod -R 755 /var/lib/roundcube
chown -R www-data:www-data /var/lib/roundcube

# Reiniciar servicios
echo "Reiniciando servicios..."
systemctl restart apache2
systemctl restart postfix
systemctl restart dovecot

# Mostrar mensaje final
echo "Instalación y configuración completada."
echo "Accede a Roundcube en http://<tu_ip>/webmail"