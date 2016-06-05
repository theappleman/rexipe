; This file is maintained with Rex
; Changes will be lost if Rex is re-run

<% for my $host (@{ $hosts }) { %>
[<%= $host %>]
user = <%= $host %>
group = <%= $host %>
listen = /var/run/php-fpm.<%= $host %>.sock
listen.owner = apache
listen.group = apache
pm = static
pm.max_children = 5
;chdir = /
php_value[newrelic.appname] = <%= $host %>
php_admin_value[session.save_path] = /var/www/vhosts/<%= $host %>/tmp
<% } %>
