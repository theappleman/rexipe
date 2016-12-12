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

test {
	my $t = shift;
	$t->name("rex_gluster");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");

	$t->run_task('fw:gluster');

	my $out = run "iptables -vnL";
	$t->ok($? == 0, "iptables -vnL returns success");
	$t->ok($out =~ qr{eth0} == 1, "iptables -vnL output contains eth0");
	$t->ok($out =~ qr{eth1} == 0, "iptables -vnL output contains eth1");

	$t->finish;
};

1;
