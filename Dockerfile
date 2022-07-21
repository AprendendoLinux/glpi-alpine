FROM alpine

ADD https://php.hernandev.com/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN \
	echo "https://php.hernandev.com/v3.15/php-8.1" >> /etc/apk/repositories && \
	mkdir -p /var/www/html && \
	\
	apk update && apk upgrade && apk add \
	\
	tzdata \
	ca-certificates \
	jq \
	bash \
	curl \
	apache2 \
	icu-data-full \
	fcgi \
	php81 \
	php81-common \
	php81-session \
	php81-apache2 \
	php81-pdo_mysql \
	php81-mysqli \
	php81-mysqlnd \
	php81-ldap \
	php81-zip \
	php81-bz2 \
	php81-imap \
	php81-gd \
	php81-xml \
	php81-xmlreader \
	php81-simplexml \
	php81-xmlwriter \
	php81-curl \
	php81-mbstring \
	php81-pecl-apcu \
	php81-cgi \
	php81-soap \
	php81-posix \
	php81-gettext \
	php81-ctype \
	php81-dom  \
	php81-iconv \
	php81-intl \
	php81-fileinfo \
	php81-exif \
	php81-sodium \
	php81-opcache && \
	\
	rm /var/cache/apk/* && \
	ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/stderr /var/log/apache2/error.log

COPY httpd.conf /etc/apache2/
COPY .bashrc /root/
COPY glpi-alpine.sh change_upload_max_filesize.php default_upload_max_filesize.php /opt/
RUN chmod +x /opt/glpi-alpine.sh

WORKDIR /root
EXPOSE 80
VOLUME ["/var/www/localhost/htdocs"]
#CMD ["httpd", "-D", "FOREGROUND"]
ENTRYPOINT ["/opt/glpi-alpine.sh"]

