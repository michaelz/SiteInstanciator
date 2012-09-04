SiteInstanciator.sh

Requires : Linux (tested on Debian and Ubuntu), Apache2, MySQL, drush.

This script should do 4 things:

  1) Creates folders in configurable paths for the new website directory and the logs

  2) Sets up Apache2 by creating new virtual hosts matching the previously defined paths

  3) Creates a new database with a configurable prefix (e.g. db_ ), if necessary, using the same database user (defined in the configuration file).
   You have to know the MYSQL root password for this step.

  4) Installs Drupal, if drush is installed and working, using the previouly defined folders and database.

To set up the configuration, copy siteinstanciator_default.cfg to siteinstanciator.cfg and change your configuration.

To launch the script:

./siteinstanciator.sh test

You can also launch the script without the sitename, you will be asked to enter it afterwards.
