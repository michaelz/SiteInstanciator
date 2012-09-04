Executing siteinstanciator.sh will create a new domain and a subfolder depending on the configuration siteinstanciator.cfg. 

To set up the configuration, copy siteinstanciator_default.cfg to siteinstanciator.cfg and change your configuration.

To launch:

./siteinstanciator.sh test

You can also launch the script without the sitename, you will be asked to enter it afterwards.

This will create a virtualhost test.localhost (configurable) and a folder in /var/www/htdocs/test (configurable as well).

At the same time, the script can add a database db_sitename (configurable) with the good permissions that you can use with the user db_user (configurable).
You have to know the root password for this step.

NEW: Installation of drupal with drush. It therefore needs drush and the database described above.

