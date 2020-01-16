#!/bin/bash

while getopts 'u:p:s:' option
do
	case "${option}" in
		u) user="$OPTARG";;
		p) password="$OPTARG";;
		s) site="$OPTARG";;
esac
done

echo "Nom d'utilisateur : "$user
echo "Mot de passe : "$password
echo "site : "$site

#chemin du site
Path="/var/www/html"

#creation de la page web
mkdir $Path/$site
touch $Path/$site/index.html
echo "Bienvenue sur le site du/de "$site > $Path/$site/index.html


#creation de vhost du site
touch /etc/apache2/sites-available/$site.conf
echo "<VirtualHost *:80>
ServerAdmin $site.vinir.lan
        ServerAlias www.$site.vinir.lan
        DocumentRoot $Path/$site
        #Errorlog /var/www/html/acc/err.log
</VirtualHost>" >> /etc/apache2/sites-available/$site.conf

a2ensite $site.conf

#srv-irvin = nom du serveur dns db.vinir.lan = fichier de conf du dns
echo www.$site cname srv-irvin >> /etc/bind/db.vinir.lan
systemctl restart bind9


#creation database
mysql -u root -e "CREATE DATABASE $site;"
mysql -u root -e "CREATE USER $user;"
mysql -u root -e "GRANT ALL PRIVILEGES ON $site.*TO'$user'@'%' identified by $password;"
mysql -u root -e "FLUSH PRIVILEGES;"



useradd -p $password $user
chown $user $Path/$site
echo  "DefaultRoot $Path/$site $user" >> /etc/proftpd/proftpd.conf

systemctl reload apache2
