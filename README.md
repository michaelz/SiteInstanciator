Executing siteinstanciator.sh will create a new domain and a subfolder depending on the configuration siteinstanciator.cfg. 

To set up the configuration, copy siteinstanciator_default.cfg to siteinstanciator.cfg and change your configuration.

To launch:

./siteinstanciator.sh test

will create a virtualhost test.dev.linalis.com
and a folder ( in /var/www/dev.linalis.com/htdocs/test )

At the same time, the script can add a database linalisdev_sitename with the good permissions that you can use with the user linalis_dev.
You have to know the root password for this step.

NEW: Installation of drupal with drush. Needs drush and the database described above created.

