package mysql;

use Rex -base;

desc "Install holland";
task "holland", make {
	needs main "root" || die "Cannot gain root access";
	pkg "perl-Digest-MD5", ensure => "present";
	pkg "holland-mysqldump", ensure => "present";
	file "/etc/holland/backupsets/default.conf",
		content => template('@holland');
};

1;

__DATA__
@holland
[holland:backup]
plugin                  = mysqldump
backups-to-keep         = 31
auto-purge-failures     = yes
purge-policy            = before-backup
estimated-size-factor   = 0.3
[mysqldump]
lock-method             = auto-detect
databases               = "*"
tables                  = "*"
dump-routines           = no
dump-events             = no
stop-slave              = no
bin-log-position        = no
flush-logs              = no
file-per-database       = yes
additional-options      = ""
[compression]
method                  = gzip
inline                  = yes
level                   = 1
@end
