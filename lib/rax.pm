package rax;

use Rex -base;

desc "[CentOS] image servicing";
task "image", group => "rax", make {
	file "/etc/sysconfig/network-scripts/ifcfg-host0",
		source => "files/ifcfg-host0";
	file "/usr/local/bin/image-services",
		source => "files/image-services.sh",
		owner => "root",
		group => "root",
		mode => 744;
};

1;
