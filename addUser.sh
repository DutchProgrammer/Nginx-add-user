#!/bin/bash
MySQL_username='root'
MySQL_password='password'
MySQL_virtualDomains='domains'
mailServerDatabase='mailserver' #Incase your using an database for you mailserver

echo "This program will add an user, home dir and activate the domain"

echo "What username do you wanna user ? [username]"
read username

echo "Username has been set $username"
echo ""

echo "What domain do you wanna user ? [domain.nl]"
read domain

echo "Domain has been set to $domain"

#echo "Do you want to set php5 fpm file ? [no]"
#read php5fpm
#if [ "yes" == "$php5fpm" ]
#then
#
#   defaultPHPfpm="./default.com.conf"
#   PHPfpmFile="/etc/php5/fpm/pool.d/$domain.conf"
#
#   echo ""
#   echo "Create PHPfpm file"
#   echo ""
#
#   cp $defaultPHPfpm $PHPfpmFile
#
#   perl -pi -e "s/default.com/$domain/g" $PHPfpmFile
#   perl -pi -e "s/defaultAccount/$username/g" $PHPfpmFile
#
#   echo "PHP5 fpm file created"
#fi

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
echo "Work in progress" > /home/$username/domains/$domain/public_html/index.php

echo "Do you want to add this domain to your mailserver ? [no]"
read addDomain

if [ "$addDomain" == "yes" ]
then
  mysql --user="$MySQL_username" --password="$MySQL_password" -D $mailServerDatabase -e "INSERT INTO $MySQL_virtualDomains (domain) VALUES ('$domain');"
  mysql --user="$MySQL_username" --password="$MySQL_password" -e "CREATE DATABASE IF NOT EXISTS "$username"_datab; GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER ON "$username"_datab.* TO '$username'@'localhost' IDENTIFIED BY '$newPassword';FLUSH PRIVILEGES;"
fi

echo "Username and domain has been created"
