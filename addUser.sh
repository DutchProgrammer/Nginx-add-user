#!/bin/bash
MySQL_username='root'
MySQL_password='password'
mailServerDatabase='mailserver' #Incase your using an database for you mailserver

echo "This program will add an user, home dir and activate the domain"

echo "What username do you wanna user ? [username]"
read username

echo "Username has been set $username"
echo ""

echo "What domain do you wanna user ? [domain.nl]"
read domain

echo "Domain has been set to $domain"

defaultPHPfpm="./default.com.conf"
PHPfpmFile="/etc/php5/fpm/pool.d/$domain.conf"

echo ""
echo "Create PHPfpm file"
echo ""

cp $defaultPHPfpm $PHPfpmFile

perl -pi -e "s/default.com/$domain/g" $PHPfpmFile
perl -pi -e "s/defaultAccount/$username/g" $PHPfpmFile

defaultSite="./default.com"
availableDir="/etc/nginx/sites-available/$domain"
enableDir="/etc/nginx/sites-enabled/$domain"

echo ""
echo "start creating user and set domain"
echo ""

useradd $username -d /home/$username
newPassword=$(openssl rand -hex 8)

echo -e "$newPassword\n$newPassword\n" | passwd $username 

echo "Account password has been set to $newPassword"
echo ""

cp $defaultSite $availableDir

perl -pi -e "s/default.com/$domain/g" $availableDir
perl -pi -e "s/defaultAccount/$username/g" $availableDir

#cp $availableDir $enableDir

cd /etc/nginx/sites-enabled && ln -s $availableDir $domain

service nginx reload

mkdir -p /home/$username/domains/$domain/public_html && chown $username:$username /home/$username/ -R
echo "Work in progress" >> /home/$username/domains/$domain/public_html/index.php

mysql --user="$MySQL_username" --password='$MySQL_password' -D $mailServerDatabase -e "INSERT INTO virtual_domains (id, name) VALUES (NULL, '$domain');"
mysql --user="$MySQL_username" --password='$MySQL_password' -e "CREATE DATABASE IF NOT EXISTS $username_datab; GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER ON $username_datab.* TO '$username'@'localhost' IDENTIFIED BY '$newPassword';FLUSH PRIVILEGES;"

echo "Username and domain has been created"
