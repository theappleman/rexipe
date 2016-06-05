use Rex::Test::Base;
use Rex -base;

set box => "KVM";

test {
	my $t = shift;

	$t->name("rex_gluster");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task('gluster:install');

	$t->has_package("glusterfs-server");
	$t->has_service_running("glusterd");

	$t->has_dir("/home/gluster");

	$t->finish;
};

1;
