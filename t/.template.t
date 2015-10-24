use Rex::Test::Base;
use Rex -base;

set box => "KVM";

test {
	my $t = shift;

	$t->name("rex__test");

	#$t->base_vm("http://box.rexify.org/box/ubuntu-server-12.10-amd64.ova");
	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");
	$t->run_task("setup");

	$t->has_package("vim");
	$t->has_package("ntp");
	$t->has_package("unzip");

	$t->has_file("/etc/ntp.conf");

	#$t->has_service_running("ntp");

	$t->has_content("/etc/passwd", qr{root:x:0:}ms);

	run "ls -l";
	$t->ok($? == 0, "ls -l returns success.");

	$t->finish;
};

1; # last line
