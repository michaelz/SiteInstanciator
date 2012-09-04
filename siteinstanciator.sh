#! /bin/bash

# root ?
if [ "$(whoami)" != "root" ]; then
	echo "Please run this script as root or with sudo"
	exit 1
fi
# defining sitename

SITENAME=$1
if [ -z $1 ]
 then echo -n "Please enter the site's machine name: " ; read SITENAME
fi

CONFIGFILE="siteinstanciator.cfg"

# CONFIGURATION -- Do not edit, use the $CONFIGFILE defined above instead.

SERVERHOST="localhost"
SERVERNAME="$SITENAME.$SERVERHOST"
SERVERADMIN="root@localhost"
DEVPATH="/var/www/htdocs"

APACHEUSER="www-data"
A2VIRTUALHOST="*"
LOGPATH="/var/www/log"
A2ERRORLOG="$LOGPATH/$SITENAME.$SERVERHOST-error.log"
A2TRANSFERLOG="$LOGPATH/$SITENAME.$SERVERHOST-access.log"
A2FILE="/etc/apache2/sites-available/$SERVERHOST"

DBDEVUSER="dbuser"
DBDEVHOST="localhost"
DBDEVPW=""
DBDEVPREFIX="db_"
DBDEVNAME="$DBDEVPREFIX$SITENAME"





# SCRIPT

if test -d $DEVPATH/$SITENAME; then
  echo "Folder $DEVPATH/$SITENAME already exists."; exit 0;
fi 
if [ -f $CONFIGFILE ]; then
  echo -n "Loading configuration file $CONFIGFILE "
  . $CONFIGFILE
  echo ".. [OK]"
  echo " "
fi
echo "This script will create a new site called $SERVERNAME. Please check this configuration before continuing:"
echo "Install path: $DEVPATH/$SITENAME"
echo "Servername: $SERVERNAME"
echo "Serveradmin: $SERVERADMIN"
echo "Apache2 virtual host: $A2VIRTUALHOST"
echo "Apache2 virtualhost file: $A2FILE"
echo "Log folder: $LOGPATH"
echo " " 
echo -n "Do you want to proceed (y/N)? "
read answer
if test "$answer" != "Y" -a "$answer" != "y"; then 
  echo "Aborted by user."
  exit 0;
fi
echo "OK, let's go."
# Apache2 file information
while [ -z $SERVERADMIN ]; do echo -n "Please enter ServerAdmin e-mail: " ; read SERVERADMIN; done


echo -n "Creating $DEVPATH/$SITENAME/htdocs"
mkdir -p $DEVPATH/$SITENAME/htdocs
echo " [OK]"
echo " "
echo -n "Setting up apache... "

# Setting up apache file
echo " <VirtualHost $A2VIRTUALHOST:80>" >> $A2FILE
echo "	ServerAdmin $SERVERADMIN" >> $A2FILE
echo "	ServerName $SERVERNAME" >> $A2FILE
echo " " >> $A2FILE
echo "	DocumentRoot $DEVPATH/$SITENAME/htdocs" >> $A2FILE
echo "  <Directory $DEVPATH/$SITENAME/htdocs/>" >> $A2FILE
echo "     Options Indexes FollowSymLinks MultiViews" >> $A2FILE
echo "     AllowOverride All " >> $A2FILE
echo "     Order allow,deny" >> $A2FILE
echo "     Allow from all " >> $A2FILE
echo "  </Directory>" >> $A2FILE
echo " " >> $A2FILE
echo "  ErrorLog $A2ERRORLOG" >> $A2FILE
echo "  TransferLog $A2TRANSFERLOG >> $A2FILE "
echo " " >> $A2FILE
echo "</VirtualHost>" >> $A2FILE
sleep 1
echo "[OK]"
echo -n "chmoding and chowning... "
chown -R www-data:www-data $DEVPATH/$SITENAME
chmod -R 775 $DEVPATH/$SITENAME
echo "[OK]"
sleep 1
echo "All done. You should restart the apache2 server to enable the virtualhost. To disable all the dev sites, a2dissite $A2FILE."
echo "Your webfolder is accessible here : $DEVPATH/$SITENAME/htdocs."
echo " "
sleep 1
echo "This will create a local database $DBDEVNAME (You must know your root password)"
sleep 1
echo -n "Do you want to proceed ? (y/N) "
read answer
if test "$answer" != "Y" -a "$answer" != "y";
then exit 0;
fi
echo "OK, let's go. Trying to create database $DBDEVNAME and to grant privileges... "
echo -n "Please enter mysql root password : "
read -s MYSQLPASS
if [ -z `mysql -u root -p$MYSQLPASS -e 'SHOW DATABASES' | grep -x $DBDEVNAME` ] ; then
  mysql -u root -p$MYSQLPASS -e "CREATE DATABASE $DBDEVNAME" || exit 0
else
  echo " "
  echo -n "Database exists. Giving permissions only."
fi
mysql -u root -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON $DBDEVNAME.* to '$DBDEVUSER'@'$DBDEVHOST'" && echo "[OK]" || exit 0
echo " "
sleep 1
echo "Your database information:"
echo "database : $DBDEVNAME"
echo "user : $DBDEVUSER"
echo "host : $DBDEVHOST"
echo "password : $DBDEVPW"
echo " "
sleep 1
echo "Testing if drush is installed"
if [ ! -z `type -P drush` ]; then
  sleep 1
  echo -n "Would you like to install Drupal in its latest version ? [Y/N] "
  read answer
  if test "$answer" != "Y" -a "$answer" != "y";
    then exit 0;
  fi
  echo "Downloading Drupal..."
  cd $DEVPATH/$SITENAME
  drush dl
  echo "Deleting existing htdocs"
  rmdir htdocs
  if [ -d htdocs ]; then 
    echo "There was a problem deleting htdocs folder. Are there any files in it ? Aborting site installation."
  else
    echo "Renaming `echo drupal*` to htdocs"
    mv drupal-* htdocs
    echo "Chowning and chmoding"
    chown -R www-data:www-data $DEVPATH/$SITENAME
    chmod -R g+w $DEVPATH/$SITENAME
    echo "Get into htdocs"
    cd htdocs
    echo "You are now in `pwd`. Executing drush site-install"
    echo " "
    drush site-install --db-url=mysql://$DBDEVUSER:$DBDEVPW@$DBDEVHOST/$DBDEVNAME --site-name="$SITENAME"
    [ -d sites/default/files ] && chown -R www-data:www-data sites/default/files && chmod 777 sites/default/files
  fi  
else
  echo "Drush not installed. Sorry, no drupal installation possible."
fi
echo "All Done ! Bye."
