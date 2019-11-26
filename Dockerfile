FROM debian:buster

#Port mapping when we intend to run the container after  building the image
#80/tcp-http 443/tcp-https
EXPOSE 80 443

ENV DEBIAN_FRONTEND noninteractive
RUN echo "mysql-apt-config mysql-apt-config/select-server select mysql-5.7" | debconf-set-selections

#update && upgrade the file system packeges
RUN apt update && apt -y upgrade

#installing the services and there dependencies
RUN apt install -y vim && apt install -y nginx \
	&& apt install -y php7.3-fpm \
	&& apt install -y php7.3-mbstring \
	&& apt install -y php-mysql \
	&& apt install -y lsb-release \
	&& apt install -y gnupg \
	&& apt install -y wget

#installing mysql 5.7
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.14-1_all.deb \
	&& dpkg -i /mysql-apt-config_0.8.14-1_all.deb \
	&& apt-get update \
	&& apt-get install -y mysql-server
#installing the phpmyadmi UI
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-english.tar.gz \
	&& tar -xvf phpMyAdmin-4.9.2-english.tar.gz \
	&& rm phpMyAdmin-4.9.2-english.tar.gz \
	&& mv /phpMyAdmin-4.9.2-english /var/www/html/phpmyadmin \
	&& chown -R www-data:www-data /var/www/html/phpmyadmin

#set the wordpress folder in the root of the webserver
ADD wordpress /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress
COPY wordpress/wp-config.php /var/www/html/wordpress/wp-config-sample.php
#generate the SSL Key and Certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=New York/L=Brooklyn/O=Example Brooklyn Company/CN=localhost" \
	&& touch /etc/nginx/snippets/self-signed.conf \
	&& echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;" >> /etc/nginx/snippets/self-signed.conf \
	&& echo "ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" >> /etc/nginx/snippets/self-signed.conf

#configure the webserver"Nginx" Default configue file
COPY default /etc/nginx/sites-available/default

#configure the phpmyadmin config.sample.inc.php
COPY config.inc.php /var/www/html/phpmyadmin/config.sample.inc.php
RUN mv /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php

#copy needed file to set up the database tables
COPY privilege.sql /var/www/html/phpmyadmin
COPY setupservices.sh /setupservices.sh
RUN chmod 777 /setupservices.sh
#RUN chown -R mysql: /var/lib/mysql

ENTRYPOINT ["/setupservices.sh"]
