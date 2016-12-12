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

use Rex::Commands::Sync;
use POSIX qw(strftime);
desc "Copy holland data down to host";
task "sync_down", make {
	needs main "root" || die "Could not elevate privileges";
	my $date = strftime "%F", localtime;
	my $srv = connection->server;
	LOCAL {
		file $srv,
			ensure => "directory";
		file join("/", ($srv, $date)),
			ensure => "directory";
		file join("/", ($srv, $date,"holland")),
			ensure => "directory";
	};
	if (is_dir("/var/lib/mysqlbackup")) {
		sync_down "/var/lib/mysqlbackup",
			join("/", (connection->server, $date, "holland")),
			{
				files => {
					mode => 644,
				},
			};
	}
	if (is_dir("/var/spool/holland")) {
		sync_down "/var/spool/holland",
			join("/", (connection->server, $date, "holland")),
			{
				files => {
					mode => 644,
			},
		};
	}
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
