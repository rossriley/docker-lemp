FROM        ubuntu:saucy
MAINTAINER  Ross Riley "riley.ross@gmail.com"

# Install nginx
RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Internal Port Expose
EXPOSE 80 443

# Install PHP5 and modules
RUN apt-get install -y curl git
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli
RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure nginx for PHP websites
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/London;" >> etc/php5/fpm/php.ini


VOLUME ["/data/mysql"]
# Install MariaDB
RUN apt-get -y install software-properties-common
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu saucy main'
RUN apt-get update
RUN apt-get -y install mariadb-server
RUN sed -i 's/^innodb_flush_method/#innodb_flush_method/' /etc/mysql/my.cnf
RUN sed -i "/^datadir*/ s|=.*|=/data/mysql|" /etc/mysql/my.cnf
RUN mysql_install_db
RUN chown -R mysql:mysql /data/mysql


RUN apt-get install -y supervisor
ADD supervisor/nginx.conf /etc/supervisor/conf.d/
ADD supervisor/php.conf /etc/supervisor/conf.d/
ADD supervisor/mariadb.conf /etc/supervisor/conf.d/

ADD config/nginx.conf /etc/nginx/sites-available/default



CMD ["/usr/bin/supervisord", "-n"]