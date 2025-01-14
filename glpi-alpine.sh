#!/bin/bash

[[ ! "$VERSION" ]] \
	&& VERSION=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "$TIMEZONE" ]]; then echo "O TIMEZONE nao esta definido"; 
	else 
		echo "date.timezone = \"$TIMEZONE\"" >> /etc/php81/php.ini
		echo "session.cookie_httponly = On" >> /etc/php81/php.ini
		ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

if [[ -z "$UPLOAD_MAX_FILESIZE" ]];
then 

		if [ -z "$(ls -A /var/www/localhost/htdocs)" ]; then
			echo "Diretorio vazio, nada a fazer"
		else
			php81 /opt/default_upload_max_filesize.php
		fi

	else
		sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /etc/php81/php.ini


		if [ -z "$(ls -A /var/www/localhost/htdocs)" ]; then
			echo "Diretorio vazio, nada a fazer"
		else
			php81 /opt/change_upload_max_filesize.php
		fi

fi

if [[ -z "$POST_MAX_FILESIZE" ]]; then echo "O POST_MAX_FILESIZE nao esta definido";
	else
		sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /etc/php81/php.ini
fi

LINK_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/$VERSION | jq .assets[0].browser_download_url | tr -d \")

## Ajustando TLS LDAP
if !(grep -q "TLS_REQCERT" /etc/openldap/ldap.conf)
then
    echo -e "TLS_REQCERT\tnever" >> /etc/openldap/ldap.conf
fi

## Extraindo o instalador do GLPI
if [ -z "$(ls -A /var/www/localhost/htdocs)" ]; then
	wget -q $LINK_GLPI --output-document=/tmp/glpi.tar.gz
	tar -zxf /tmp/glpi.tar.gz -C /tmp
	mv /tmp/glpi/{.[!.],}* /var/www/localhost/htdocs/
	rm -rf /tmp/glp*
	chown -R apache:apache /var/www/localhost/htdocs/
else
	echo "O GLPI ja se encontra instalado"
fi

## Adicionando regra no crontab para forcar o script php a rodar
echo '*/2 * * * * /usr/bin/php81 /var/www/localhost/htdocs/front/cron.php 2>&- 1>&-' >> /etc/crontabs/root

## Subindo o crontrab
crond -b -d 0

## Subindo o apache
httpd -D FOREGROUND
