package docker;

use Rex -base;

desc "Install docker";
task "install", make {
	needs main "root" || die "Cannot gain root access";
	pkg "docker", ensure => "latest";
	service "docker", ensure => "started";
	append_if_no_such_line "/etc/yum.conf",
		"exclude=docker*";
};

1;
