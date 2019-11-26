#!/bin/bash
chown -R mysql: /var/lib/mysql
service mysql restart
service php7.3-fpm start
service nginx restart
#mysql < /var/www/html/phpmyadmin/sql/create_tables.sql -u root -p
#mysql < /var/www/html/phpmyadmin/privilege.sql -u root -p
mysql --user=root -e "source /var/www/html/phpmyadmin/sql/create_tables.sql;"
mysql --user=root -e "source /var/www/html/phpmyadmin/privilege.sql;"
exec /bin/bash
