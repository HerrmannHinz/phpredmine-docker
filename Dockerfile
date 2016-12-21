FROM alpine:3.4
RUN echo "http://dl-3.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
RUN apk --update add redis php5-apache2 curl php5-cli php5-json php5-phar php5-openssl php5-redis && \
    rm -f /var/cache/apk/* && \
    echo "extension=redis.so" >/etc/php5/conf.d/redis.ini && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir /run/apache2/ && chown -R apache:apache /run/apache2/

ENV RELEASE=master

RUN cd /var/www/localhost && \
    curl -q  https://github.com/sasanrose/phpredmin/archive/$RELEASE.tar.gz > phpredmin-$RELEASE.tar.gz && \
    tar xzf  phpredmin-$RELEASE.tar.gz && \
    rm phpredmin-$RELEASE.tar.gz && \
    rm -rf htdocs/ && mv phpredmin-$RELEASE htdocs

COPY files/config.php /var/www/localhost/htdocs/config.php
COPY files/run.sh /var/www/localhost/run.sh
RUN mkdir -p -m 0777 /var/www/localhost/htdocs/logs/apache2handler/ && \
    chmod a+x /var/www/localhost/run.sh

RUN sed 's|/var/www/localhost/htdocs|/var/www/localhost/htdocs/public|g' /etc/apache2/httpd.conf >/etc/apache2/httpd-new.conf && \
    echo "ServerName localhost" >> /etc/apache2/httpd-new.conf && \
    mv /etc/apache2/httpd-new.conf /etc/apache2/httpd.conf

EXPOSE 80

WORKDIR /var/www/localhost/htdocs/

ENTRYPOINT ["/var/www/localhost/run.sh"]
