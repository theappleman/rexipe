package gluster;

use Rex -base;

desc "Install glusterfs";
task "install", make {
	needs main "root" || die "Could not elevate privileges";

	repository "add" => "glusterfs",
		url => 'http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/epel-$releasever/$basearch/',
		gpgkey => 'http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/pub.key';

	pkg "epel-release", ensure => "latest";
	pkg "glusterfs-server", ensure => "latest";

	service "glusterd", ensure => "started";

	file "/home/gluster",
		ensure => "directory";
};

1;
