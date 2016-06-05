# This file is maintained with Rex
# Changes will be lost if Rex is re-run

<% foreach $vhost (@{ $hosts }) { %>
<VirtualHost *:80>
	ServerName <%= $vhost %>
	DocumentRoot /var/www/vhosts/<%= $vhost %>/httpdocs
	ErrorLog logs/<%= $vhost %>-error.log
	CustomLog logs/<%= $vhost %>-access.log forwarded env=forwarded
	CustomLog logs/<%= $vhost %>-access.log combined  env=!forwarded

	Alias /.well-known/acme-challenge /var/www/acme-challenge/.well-known/acme-challenge

	<IfModule mod_fastcgi.c>
		Alias /php5-fcgi /dev/shm/<%= $vhost %>.fpm
	</IfModule>

	<IfModule mod_proxy_fcgi.c>
		<Proxy "unix:/var/run/php-fpm.<%= $vhost %>.sock|fcgi://php-fpm">
			# we must declare a parameter in here (doesn't matter which) or it'll not register the proxy ahead of time
			ProxySet disablereuse=off
		</Proxy>
		<FilesMatch \.php$>
			SetHandler "proxy:fcgi://php-fpm"
		</FilesMatch>
	</IfModule>

	<Directory /var/www/vhosts/<%= $vhost %>/httpdocs>
		AllowOverride all
	</Directory>

	<IfModule mod_authz_core.c>
		<Directory /var/www/vhosts/<%= $vhost %>/httpdocs>
			Require all granted
		</Directory>
		<Directory /var/www/vhosts/<%= $vhost %>/httpdocs/.git>
			Require all denied
		</Directory>
	</IfModule>
</VirtualHost>

<% if (grep {$_ eq $vhost} @{ $ssls }) { %>
<VirtualHost *:443>
	ServerName <%= $vhost %>
	DocumentRoot /var/www/vhosts/<%= $vhost %>/httpdocs
	ErrorLog logs/<%= $vhost %>-ssl-error.log
	CustomLog logs/<%= $vhost %>-ssl-access.log forwarded env=forwarded
	CustomLog logs/<%= $vhost %>-ssl-access.log combined  env=!forwarded

	Alias /.well-known/acme-challenge /var/www/acme-challenge/.well-known/acme-challenge

	SSLEngine On
	SSLCertificateFile /etc/letsencrypt/live/<%= $vhost %>/cert.pem
	SSLCertificateChainFile /etc/letsencrypt/live/<%= $vhost %>/chain.pem
	SSLCertificateKeyFile /etc/letsencrypt/live/<%= $vhost %>/privkey.pem

	<IfModule mod_fastcgi.c>
		Alias /php5-fcgi /dev/shm/<%= $vhost %>.fpm
	</IfModule>

	<IfModule mod_proxy_fcgi.c>
		<Proxy "unix:/var/run/php-fpm.<%= $vhost %>.sock|fcgi://php-fpm">
			# we must declare a parameter in here (doesn't matter which) or it'll not register the proxy ahead of time
			ProxySet disablereuse=off
		</Proxy>
		<FilesMatch \.php$>
			SetHandler "proxy:fcgi://php-fpm"
		</FilesMatch>
	</IfModule>

	<Directory /var/www/vhosts/<%= $vhost %>/httpdocs>
		AllowOverride all
	</Directory>

	<IfModule mod_authz_core.c>
		<Directory /var/www/vhosts/<%= $vhost %>/httpdocs>
			Require all granted
		</Directory>
		<Directory /var/www/vhosts/<%= $vhost %>/httpdocs/.git>
			Require all denied
		</Directory>
	</IfModule>
</VirtualHost>
<% } %>

<% } %>
