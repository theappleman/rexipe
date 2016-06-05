use Rex::Test::Base;
use Rex -base;

set box => "KVM";

test {
	my $t = shift;

	$t->name("rex_docker_test");

	$t->base_vm("http://box.rexify.org/box/centos-7-amd64.ova");
	$t->vm_auth(user => "root", password => "box");
	$t->run_task("docker:install");

	$t->has_package("docker");

	#$t->has_service_running("ntp");

	run "docker info";
	$t->ok($? == 0, "docker info returns success.");

	$t->finish;
};

1; # last line
