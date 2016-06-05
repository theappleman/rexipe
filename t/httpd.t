use Rex::Test::Base;
use Rex -base;

set box => "KVM";
sudo FALSE;

test {
	my $t = shift;

	$t->name("rex_httpd-users");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task("web:users");
	$t->has_content("/etc/passwd", qr{xxoo\.ws:});
	$t->finish;
};

test {
	my $t = shift;

	$t->name("rex_httpd");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task('web:apache');
	#$t->run_task('web:server');

	$t->has_package("httpd");
	$t->has_service_running("httpd");

	$t->has_dir("/etc/httpd/vhosts.d");
	$t->has_dir("/var/www/vhosts");
	$t->has_content("/etc/httpd/conf/httpd.conf", qr{IncludeOptional vhosts\.d/\*\.conf});

	$t->finish;
};

test {
	my $t = shift;

	$t->name("rex_httpd");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task("web:phpfpm");

	$t->has_package("php56u-fpm");
	$t->has_file("/etc/php-fpm.d/www.conf");

	$t->has_service_running("php-fpm");

	$t->finish;
};

test {
	my $t = shift;

	$t->name("rex_httpd");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task("web:netrc");
	$t->ok(1, "task run successfully");
	$t->finish;
};

test {
	my $t = shift;

	$t->name("rex_httpd_clean");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task("web:server");
	$t->ok(1, "task run successfully");
	$t->finish;
};

1;
